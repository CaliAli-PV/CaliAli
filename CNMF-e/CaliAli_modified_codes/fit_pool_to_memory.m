function nw = fit_pool_to_memory(neuron, n_seeds)
%% fit_pool_to_memory: Shrink the parallel pool so extraction fits in free memory.
%
% Worker count is what decides peak memory during extraction: an idle pool of
% 16 workers holds about 18 GiB before any data is loaded, and each busy worker
% then holds its patch for every frame. Nothing else in CaliAli picks the pool
% size, so by default extraction runs on one worker per physical core however
% little memory the machine has free.
%
% This predicts the peak for the pool that would be used, and if it does not fit
% in free memory, starts the largest pool that does. It never grows a pool.
%
% Inputs:
%   neuron  - Sources2D after getReady, so the patch layout is known.
%   n_seeds - number of seeds extraction starts from. Peak memory grows with
%             neuron count, which is not known yet; seeds were 1.0-2.3x the
%             final count in every measurement, so they err on the safe side.
%
% Outputs:
%   nw - number of workers extraction will use (0 = no pool).
%
% Notes:
%   - The prediction is from measurements on Linux (see predict_peak_GiB).
%   Memory already held by this MATLAB and an existing pool is not free, but is
%   part of the prediction, so it is added back to the budget.
%
% Author: Pablo Vergara

nw = 0;
if isprop(neuron,'use_parallel') && ~isempty(neuron.use_parallel) && ~neuron.use_parallel
    return
end
if isempty(which('parpool'))
    return
end

% How many workers would extraction use if left alone?
p = gcp('nocreate');
if ~isempty(p)
    nw_req = p.NumWorkers;
    cluster = p.Cluster;
else
    ps = parallel.Settings;
    if ~ps.Pool.AutoCreate
        return          % parfor will run in this process; nothing to size
    end
    cluster = parcluster();
    nw_req = cluster.NumWorkers;    % what an automatic pool starts with
end
nw = nw_req;

try
    [~, free_GiB] = getSystemMemory;
catch
    return              % cannot tell; leave the pool alone
end
held = 1.30 + 1.05*double(~isempty(p))*nw_req;   % idle client + pool, already resident
budget = free_GiB + held;

d1 = neuron.options.d1;
d2 = neuron.options.d2;
T  = neuron.P.numFrames;
n_patches = numel(neuron.P.mat_data.patch_pos);

peak = arrayfun(@(n) predict_peak_GiB(d1, d2, T, n_patches, n_seeds, n), 1:nw_req);
if double(d1)*double(d2)*double(T) > 2.7e8
    cprintf('-comment', ['Predicted extraction memory is an extrapolation: the rule was ' ...
        'measured up to 2.7e8 pixels x frames, this recording has %.1e.\n'], ...
        double(d1)*double(d2)*double(T));
end
fits = find(peak <= budget, 1, 'last');
if isempty(fits)
    % Even one worker is predicted not to fit. Fewer workers cannot save it, and
    % at this size the prediction is likely far outside the measured range, so
    % leave the pool alone rather than slow extraction down on a guess.
    cprintf('*red', ['Extraction is predicted to need %.1f GB even with 1 worker, ' ...
        'but only %.1f GB is free. It may run out of memory.\n'], peak(1), budget);
    return
end
nw = fits;
if nw == nw_req
    return
end

cprintf('*red', ['Extraction with %d workers is predicted to peak at %.1f GB, ' ...
    'but %.1f GB is free. Using %d workers instead (predicted %.1f GB).\n'], ...
    nw_req, peak(nw_req), budget, nw, peak(nw));
delete(gcp('nocreate'));
parpool(cluster, nw);
end


function peak = predict_peak_GiB(d1, d2, T, n_patches, n_seeds, nw)
%% Peak memory of extraction, client plus pool, in GiB.
% Fitted to the summed high-water mark of every MATLAB process in 43 runs:
% frames 128x181 to 283x398, 446 to 5216 frames, 44 to 451 neurons, 2 to 16
% workers, up to 2.7e8 pixels x frames (memory_rule/STATUS.md). A worker with a
% patch to work on holds that patch for every frame, plus memory in proportion
% to the patch area and to the neurons in it, so these costs stop growing once
% there are more workers than patches. The last term is the worst
% under-prediction on a recording left out of the fit, so within the tested
% range the rule errs high.
elements = double(d1)*double(d2)*double(T);
busy = min(nw, n_patches);
patch_px = double(d1)*double(d2)/n_patches;
seeds_per_patch = n_seeds/n_patches;
peak = 1.41 + 0.893*nw + 67.0*elements/2^30 ...
    + busy*(116e-6*patch_px + 11.9e-3*seeds_per_patch + 42.3*patch_px*double(T)/2^30) ...
    + 2.3;
end
