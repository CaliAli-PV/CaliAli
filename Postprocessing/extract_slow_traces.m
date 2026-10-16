function out = extract_slow_traces(neuron, varargin)
%% extract_slow_traces: Traces that keep slow activity, read with the extracted footprints.
%
% The extraction removes slow activity on purpose: the video is detrended before
% it, and the final traces are detrended again. That is right for calcium
% transients and wrong for a slow signal of interest, such as a baseline that
% cycles over tens of seconds. This function leaves the extraction as it is and
% reads the traces a second time, from the motion-corrected videos, which were
% never detrended:
%
%   1. each motion-corrected session is put through the same crops, translation
%      and non-rigid warps the alignment applied, so it lands in the frame the
%      footprints were extracted in;
%   2. every frame is projected onto all the footprints together (least
%      squares), so overlapping neurons do not share each other's activity;
%   3. each trace's median within each session is taken as its baseline (F0)
%      and subtracted.
%
% No background model is fitted. CNMF-E's ring background can rebuild a
% neuron's slow activity from its neighbours and take it away, which is what
% this function avoids. Instead, background = 'ring' subtracts ring_factor
% times the changes of the mean of a ring around each neuron, with every
% footprint left out of every ring, as is usual for two-photon neuropil.
%
% On a simulated recording whose neurons and background each carried a slow
% cycle (period 20-60 s), these traces kept 82% of the cycle (correlation 0.90
% with the true one), against 1% for the extraction's own C_raw.
%
% Nothing in the neuron is changed. The traces are in the units of the
% motion-corrected video, so dff = traces ./ F0 is available; F0 includes the
% background under the footprint.
%
% Inputs:
%   neuron   - Sources2D object returned by CaliAli_cnmfe, or the path to a
%              saved extraction (.mat holding 'neuron'). Its CaliAli_options
%              must be the ones saved by CaliAli_align_sessions.
%   Name-value:
%   'background'      - 'none' (default) or 'ring'.
%   'ring_factor'     - Fraction of the ring mean subtracted (default 0.7).
%   'ring_radius'     - [inner outer] distance of the ring from the footprint,
%                       in pixels (default [gSig, 5*gSig]).
%   'CaliAli_options' - Options to use instead of neuron.CaliAli_options.
%
% Outputs:
%   out - Structure with fields:
%         traces            K x T, baseline removed in each session
%         dff               K x T, traces ./ F0 (NaN where F0 <= 0)
%         F0                K x sessions, the baseline of each trace
%         frames_per_session
%         ids               neuron.ids, the neuron each row belongs to
%         background, ring_factor, ring_radius
%         match             median correlation of the fast part of each trace
%                           with the extraction's C_raw: low means the
%                           footprints do not sit on this video
%
% Usage:
%   out = extract_slow_traces(neuron);
%   out = extract_slow_traces('rec_Aligned_source_extraction/.../result.mat', 'background', 'ring');
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

p = inputParser;
p.addParameter('background', 'none', @(x) any(strcmpi(x, {'none', 'ring'})));
p.addParameter('ring_factor', 0.7, @(x) isnumeric(x) && isscalar(x));
p.addParameter('ring_radius', [], @(x) isempty(x) || (isnumeric(x) && numel(x) == 2));
p.addParameter('CaliAli_options', [], @(x) isempty(x) || isstruct(x));
p.parse(varargin{:});
arg = p.Results;

if ischar(neuron) || isstring(neuron)
    L = load(char(neuron), 'neuron');
    neuron = L.neuron;
end
opt = arg.CaliAli_options;
if isempty(opt), opt = neuron.CaliAli_options; end
a = alignment_record(opt);

d1 = neuron.options.d1; d2 = neuron.options.d2;
A = neuron.A;
K = size(A, 2);
F = a.F(:)';
T = sum(F);
if K == 0, error('CaliAli:slowTraces:noNeurons', 'The extraction holds no neurons.'); end
if size(neuron.C_raw, 2) ~= T
    error('CaliAli:slowTraces:frames', ['The extraction has %d frames but the alignment ' ...
        'recorded %d.'], size(neuron.C_raw, 2), T);
end

% Least squares on all footprints at once. A tiny ridge keeps the system
% solvable when two footprints are nearly identical.
G = full(A' * A);
G = G + 1e-9 * trace(G) / K * eye(K);
Gd = decomposition(G);

ring_on = strcmpi(arg.background, 'ring');
radius = arg.ring_radius;
if ring_on
    if isempty(radius)
        gSig = min(neuron.options.gSig);
        radius = [max(1, round(gSig)), max(2, round(5 * gSig))];
    end
    [R, scale] = ring_matrix(A, d1, d2, radius);
end

C = zeros(K, T);
Rt = zeros(K, T);
offset = [0, cumsum(F)];
files = a.input_files;
for k = 1:numel(files)
    [entry, ses, first, last] = describe(files{k}, k);
    src = entry; if iscell(src), src = src{1}; end
    if ~isfile(src)
        error('CaliAli:slowTraces:missingVideo', ['The motion-corrected video %s is not ' ...
            'where the alignment read it. If it was moved, pass ''CaliAli_options'' with ' ...
            'inter_session_alignment.input_files pointing to it.'], src);
    end
    fprintf('Reading session %d, frames %d to %d of %s\n', ses, first, last, src);
    Y = single(CaliAli_load(entry, 'Y'));
    Y = to_extraction_frame(Y, a, ses);
    if size(Y, 1) ~= d1 || size(Y, 2) ~= d2
        error('CaliAli:slowTraces:frameMismatch', ['Session %d comes out %d x %d after the ' ...
            'alignment''s crops and warps, but the footprints are %d x %d.'], ses, size(Y, 1), size(Y, 2), d1, d2);
    end
    Y = double(reshape(Y, d1 * d2, []));
    ix = offset(ses) + (first:last);
    C(:, ix) = Gd \ full(A' * Y);
    if ring_on, Rt(:, ix) = full(R * Y); end
end

% F0 is the baseline of the trace as read, background included. The ring takes
% away only what the ring does over time: its static level is the bright,
% uneven one-photon background, and subtracting it as well pushed baselines
% below zero.
nses = numel(F);
F0 = zeros(K, nses);
traces = zeros(K, T);
for s = 1:nses
    ix = offset(s) + 1:offset(s + 1);
    F0(:, s) = median(C(:, ix), 2);
    c = C(:, ix);
    if ring_on
        c = c - arg.ring_factor * scale .* (Rt(:, ix) - median(Rt(:, ix), 2));
    end
    traces(:, ix) = c - median(c, 2);
end
base = repelem(F0, 1, F);
dff = traces ./ base;
dff(base <= 0) = NaN;
if any(F0(:) <= 0)
    warning('CaliAli:slowTraces:baseline', ['%d trace baselines are not positive, so dff is ' ...
        'NaN there.'], nnz(F0 <= 0));
end

out = struct('traces', traces, 'dff', dff, 'F0', F0, 'frames_per_session', F, ...
    'ids', neuron.ids, 'background', lower(char(arg.background)), ...
    'ring_factor', arg.ring_factor * ring_on, 'ring_radius', radius, ...
    'match', fast_match(traces, neuron.C_raw, F, frame_rate(neuron, opt)));
if out.match < 0.3
    warning('CaliAli:slowTraces:mismatch', ['The fast part of these traces correlates only %.2f ' ...
        '(median) with the extraction''s C_raw. The footprints may not sit on this video.'], out.match);
end
end


function a = alignment_record(opt)
%% The alignment fields this function needs, checked.
if ~isfield(opt, 'inter_session_alignment')
    error('CaliAli:slowTraces:noAlignment', 'These options hold no inter_session_alignment.');
end
a = opt.inter_session_alignment;
need = {'input_files', 'F', 'Mask', 'T', 'T_Mask', 'shifts', 'NR_Mask', ...
        'do_alignment_translation', 'do_alignment_non_rigid', 'final_neurons'};
miss = need(~isfield(a, need));
if ~isempty(miss) || isempty(a.input_files)
    error('CaliAli:slowTraces:noAlignment', ['The options were not saved by ' ...
        'CaliAli_align_sessions (missing: %s).'], strjoin(miss, ', '));
end
end


function [entry, ses, first, last] = describe(entry, k)
%% Session and frame range of one alignment input, a file or a batch of one.
if iscell(entry)
    ses = entry{2}; first = entry{3}; last = entry{4};
else
    ses = k; first = 1;
    dims = get_data_dimension(entry); last = dims(3);
end
end


function Y = to_extraction_frame(Y, a, ses)
%% What the alignment did to this session, in the same order.
% 1. The rectangle common to every session (match_video_size).
M = logical(a.Mask{ses});
if ~isequal(size(M), [size(Y, 1), size(Y, 2)])
    error('CaliAli:slowTraces:frameMismatch', ['Session %d is %d x %d, but the alignment ' ...
        'matched session sizes on a %d x %d frame. Was it cropped after motion correction?'], ...
        ses, size(Y, 1), size(Y, 2), size(M, 1), size(M, 2));
end
Y = Y(any(M, 2), any(M, 1), :);
% 2. The translation between sessions, then 3. the non-rigid warps, as in
% apply_transformations.
if a.do_alignment_translation
    Y = translate_and_keep(Y, a.T(ses, :), a.T_Mask);
end
if a.do_alignment_non_rigid
    Y = warp_and_keep(Y, a.shifts(:, :, :, ses), a.NR_Mask);
end
if a.final_neurons
    Y = warp_and_keep(Y, a.shifts_n(:, :, :, ses), a.NR_Mask_n);
end
end


function Y = translate_and_keep(Y, T, Mask)
%% apply_transformations' translation, and the rectangle it keeps.
[d1, d2] = size(Mask);
f1 = max(sum(Mask, 1)); f2 = max(sum(Mask, 2));
Y = imtranslate(Y, T);
Y = reshape(Y, d1 * d2, []);
Y = reshape(Y(logical(Mask), :), f1, f2, []);
end


function Y = warp_and_keep(Y, S, Mask)
%% apply_transformations' non-rigid warp, and the rectangle it keeps.
for i = 1:size(Y, 3)
    Y(:, :, i) = imwarp(Y(:, :, i), S, 'FillValues', 0);
end
f1 = max(sum(Mask, 1)); f2 = max(sum(Mask, 2));
Y = reshape(Y, size(Y, 1) * size(Y, 2), []);
Y = reshape(Y(logical(Mask(:)), :), f1, f2, []);
end


function [R, scale] = ring_matrix(A, d1, d2, radius)
%% Mean over a ring around each footprint, every footprint left out.
K = size(A, 2);
fp = reshape(full(A > 0), d1, d2, K);
taken = any(fp, 3);
rows = cell(K, 1); cols = cell(K, 1); vals = cell(K, 1);
inner_se = strel('disk', radius(1)); outer_se = strel('disk', radius(2));
empty = 0;
for k = 1:K
    ring = imdilate(fp(:, :, k), outer_se) & ~imdilate(fp(:, :, k), inner_se) & ~taken;
    idx = find(ring);
    if isempty(idx), empty = empty + 1; continue; end
    rows{k} = k * ones(numel(idx), 1); cols{k} = idx; vals{k} = ones(numel(idx), 1) / numel(idx);
end
R = sparse(vertcat(rows{:}), vertcat(cols{:}), vertcat(vals{:}), K, d1 * d2);
% The ring mean is per pixel; a trace is the amplitude of its footprint. A
% field of 1 under footprint a projects to sum(a)/sum(a.^2).
scale = full(sum(A, 1) ./ sum(A.^2, 1))';
if empty > 0
    warning('CaliAli:slowTraces:noRing', ['%d neurons have no free pixels around them; ' ...
        'nothing is subtracted from theirs.'], empty);
end
end


function m = fast_match(traces, C_raw, F, sf)
%% Median correlation of the parts faster than about 5 s.
w = max(3, round(5 * sf));
offset = [0, cumsum(F)];
hp = zeros(size(traces)); hq = hp;
for s = 1:numel(F)
    ix = offset(s) + 1:offset(s + 1);
    hp(:, ix) = traces(:, ix) - movmean(traces(:, ix), w, 2);
    hq(:, ix) = double(C_raw(:, ix)) - movmean(double(C_raw(:, ix)), w, 2);
end
r = sum(hp .* hq, 2) ./ sqrt(sum(hp.^2, 2) .* sum(hq.^2, 2));
m = median(r, 'omitnan');
end


function sf = frame_rate(neuron, opt)
sf = NaN;
try, sf = opt.preprocessing.sf; catch, end
if isempty(sf) || isnan(sf), try, sf = neuron.Fs; catch, end, end
if isempty(sf) || isnan(sf), sf = 10; end
end
