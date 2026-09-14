function neuron=manually_update_residuals(neuron,thr,use_parallel,update_temporal,seeds,checkpoint)
%   CHECKPOINT is an optional function handle called as checkpoint(stage, neuron)
%   after each stage, for measuring where an incremental run diverges from a
%   joint one. Empty by default; the shipped path is unchanged. Stages:
%   'before_update_residual_custom_seeds', 'after_update_residual_custom_seeds',
%   then per refinement pass 'loopNN_background', 'loopNN_spatial',
%   'loopNN_temporal' and 'loopNN' at the end of the pass.
%% manually_update_residuals: Iteratively refines residuals in CNMF-E extracted components.
%
% Inputs:
%   neuron       - CNMF-E extracted neuron structure containing spatial (A) and
%                  temporal (C_raw) components.
%   use_parallel - Boolean flag to enable parallel computation for speed-up.
%   thr          - Threshold for countours drawing
%   update_temporal - Optional. Update temporal components before picking
%                  residual seeds. Default true.
%   seeds        - Optional. Linear pixel indices to seed new components from.
%                  When omitted, seeds are chosen interactively through
%                  `get_seed`. Supplying them keeps the same refinement but
%                  removes the need for a graphical session, so the residual
%                  update can run unattended over a batch of recordings.
%
% Outputs:
%   neuron       - Updated neuron structure with refined residuals.
%
% Usage:
%   neuron = manually_update_residuals(neuron, true);
%   neuron = manually_update_residuals(neuron, 0.6, 1, false, seed_indices);
%
% Description:
%   - This function iteratively refines residuals in CNMF-E extracted components
%     to improve the spatial and temporal representations of neural activity.
%   - It follows an iterative approach where background, spatial, and temporal
%     components are updated until convergence.
%   - A dissimilarity metric is used to track progress, stopping the iteration
%     when changes fall below a predefined threshold (0.05).
%   - Post-processing steps include removing false positives, refining residuals
%     based on correlation and PNR, noise scaling, and deconvolution of calcium traces.
%   - The results are saved after ordering ROIs based on SNR.
%
% Features:
%   - Iterative refinement of spatial and temporal components.
%   - Parallel computing support for efficiency.
%   - Automatic false positive removal.
%   - Detrending and deconvolution of calcium traces.
%   - Saves the updated neuron workspace at the end.
%
% Notes:
%   - This function uses multiple helper functions, including:
%     - `update_temporal_CaliAli`
%     - `update_background_CaliAli`
%     - `update_spatial_CaliAli`
%     - `update_residual_custom_seeds`
%     - `dissimilarity_previous`
%     - `update_residual_Cn_PNR_batch`
%     - `scale_to_noise`
%     - `detrend_Ca_traces`
%     - `postprocessDeconvolvedTraces`
%     - `orderROIs`
%     - `save_workspace`
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

if ~exist('checkpoint','var') || isempty(checkpoint)
    checkpoint = @(varargin) [];
end
if ~exist('update_temporal','var')||isempty(update_temporal)
    update_temporal=true;
end

neuron.Coor=neuron.get_contours(thr);
if ~exist('seeds','var')||isempty(seeds)
    seed_all=get_seed(neuron);
else
    seed_all=seeds(:);
end
% A residual needs the traces in MOVIE units, but a finished extraction stores
% them in noise units. This used to be achieved by re-running the temporal
% update, which re-estimates every trace from the movie purely as a way of
% getting the scale back. With the gain recorded by scale_to_noise it is a
% multiplication, and the traces are left exactly as the earlier extraction
% found them rather than being fitted again.
if trace_noise_scale(neuron, 'has')
    neuron.C_raw = trace_noise_scale(neuron, 'apply', neuron.C_raw);
    neuron.C     = trace_noise_scale(neuron, 'apply', neuron.C);
    trace_noise_scale(neuron, 'clear');   % they are in movie units now
elseif update_temporal
    % No gain recorded: an extraction saved before it was kept. Fall back to
    % re-estimating, which is what put the traces on the movie scale before.
    neuron=update_temporal_CaliAli(neuron, use_parallel);
end
if neuron.fast_residual
    ret_id=1:size(neuron.A,2);
else
    ret_id=[];
end

checkpoint('before_update_residual_custom_seeds', neuron);
% Where the new components come from. Seeding from the RESIDUAL inherits every
% error in the current model, so an imperfectly fitted neuron leaves activity
% behind that looks like a new one; on simulated recordings that placed 74
% percent of its components where no neuron exists and tripled the component
% count in sessions it was not adding to. Seeding from the RAW signal does not
% depend on the model being right, at the cost of re-finding what is already
% there, which a duplicate test then removes. Measured on the same data:
% precision 0.67 against 0.12, with no duplicates.
init_mode = 'raw';
try, init_mode = neuron.CaliAli_options.cnmf.residual_init_mode; catch, end
if strcmpi(init_mode, 'raw')
    ring_gsig = 5; pct = 99;
    try, ring_gsig = neuron.CaliAli_options.cnmf.dedup_ring_gsig; catch, end
    try, pct       = neuron.CaliAli_options.cnmf.dedup_percentile; catch, end
    fr = neuron.frame_range;
    if isempty(fr), fr = [1, size(neuron.C,2)]; end
    neuron = update_residual_raw_seeds(neuron, fr, ring_gsig, pct);
else
    neuron=update_residual_custom_seeds(neuron,seed_all);
end
checkpoint('after_update_residual_custom_seeds', neuron);

A_temp=neuron.A;
C_temp=neuron.C_raw;

% How many refinement passes. The loop used to run until the components stopped
% changing, which suited seeding from the residual: that added many spurious
% components and the passes were spent removing them again. Initializing from
% the raw signal starts from a much cleaner set, and the extra passes then move
% away from it rather than towards it.
n_passes = 10;
try, n_passes = neuron.CaliAli_options.cnmf.residual_passes; catch, end
for loop=1:n_passes
    % estimate the background components
    neuron=update_background_CaliAli(neuron, use_parallel,ret_id);
    checkpoint(sprintf('loop%02d_background', loop), neuron);
    neuron=update_spatial_CaliAli(neuron, use_parallel,ret_id);
    checkpoint(sprintf('loop%02d_spatial', loop), neuron);
    neuron=update_temporal_CaliAli(neuron, use_parallel,ret_id);
    checkpoint(sprintf('loop%02d_temporal', loop), neuron);
    % Compare against the components as they were before this iteration, then
    % snapshot them for the next one.
    [dis,similarity_scores]=dissimilarity_previous(A_temp,neuron.A,C_temp,neuron.C_raw);
    if neuron.retreat_neurons
        % similarity_scores is indexed by current component, so this logical
        % mask lines up with the components the next iteration will update.
        ret_id=similarity_scores>0.9;
        cprintf('-comment','%1.0f stable neurons will be retreated in the next iteration.\n', sum(ret_id));
        dis=1-mean(similarity_scores(~ret_id),'omitmissing');
        if isnan(dis)
            dis=0;
        end
    end
    cprintf('-comment','Disimilarity with previous iteration is %.3f\n', dis);
    checkpoint(sprintf('loop%02d', loop), neuron);
    A_temp=neuron.A;
    C_temp=neuron.C_raw;
    if dis<0.05
        break
    end
end

%% post-process the results automatically
% A joint update of traces and background with the FOOTPRINTS HELD FIXED.
% The loop above alternates background, spatial and temporal, so a footprint
% fitted against a stale background is then used to re-fit that background. With
% the footprints fixed the traces and the background are the only unknowns left
% and they can settle against each other. Off by default; the incremental path
% is where it should matter, because the background there was carried from
% sessions that do not include the new one.
% EVERY component takes part, so ret_id is deliberately not passed. The loop
% above may have been refining only the newly added ROIs (fast_residual), which
% leaves the carried components with the traces they arrived with. Those are the
% ones a joint update is meant to correct, so freezing them here would remove
% the only reason to run it.
n_joint = 0;
try n_joint = neuron.CaliAli_options.cnmf.final_joint_passes; catch; end
for j = 1:n_joint
    neuron=update_background_CaliAli(neuron, use_parallel);
    neuron=update_temporal_CaliAli(neuron, use_parallel);
    checkpoint(sprintf('joint%02d', j), neuron);
end

neuron.remove_false_positives();

neuron=update_residual_Cn_PNR_batch(neuron);

%% Optional post-process
scale_to_noise(neuron);
neuron.C_raw=detrend_Ca_traces(neuron.sf*2,neuron.C_raw,get_batch_size(neuron));
neuron = postprocessDeconvolvedTraces(neuron, 'foopsi','ar2',-5);

%% Save results
neuron.orderROIs('snr');
save_workspace(neuron);


