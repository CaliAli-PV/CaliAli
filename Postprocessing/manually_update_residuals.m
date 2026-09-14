function neuron=manually_update_residuals(neuron,thr,use_parallel,update_temporal,seeds)
%% manually_update_residuals: Iteratively refines residuals in CNMF-E extracted components.
%
% Inputs:
%   neuron       - CNMF-E extracted neuron structure containing spatial (A) and 
%                  temporal (C_raw) components.
%   use_parallel - Boolean flag to enable parallel computation for speed-up.
%   thr          - Threshold for countours drawing
%   update_temporal - Optional. Re-estimate the traces before picking seeds.
%                  Only used when the extraction has no recorded noise scaling;
%                  see below. Default true.
%   seeds        - Optional. Linear pixel indices to seed new components from.
%                  When omitted, seeds are chosen interactively through
%                  `get_seed`. Supplying them keeps the same refinement but
%                  removes the need for a graphical session, so a residual
%                  update can run over a batch of recordings unattended.
%
% Outputs:
%   neuron       - Updated neuron structure with refined residuals.
%
% Usage:
%   neuron = manually_update_residuals(neuron, true);
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
% them in noise units because it ends with scale_to_noise. This used to be
% handled by re-running the temporal update, which re-estimates every trace from
% the movie purely as a way of recovering the scale. With the gain recorded by
% scale_to_noise it is a multiplication, and the traces are left exactly as the
% extraction found them rather than being refitted as a side effect.
if trace_noise_scale(neuron, 'has')
    neuron.C_raw = trace_noise_scale(neuron, 'apply', neuron.C_raw);
    neuron.C     = trace_noise_scale(neuron, 'apply', neuron.C);
    trace_noise_scale(neuron, 'clear');   % they are in movie units now
elseif update_temporal
    % No gain recorded: an extraction saved before it was kept. Fall back to
    % re-estimating, which is what put the traces on the movie scale before.
    neuron=update_temporal_CaliAli(neuron, use_parallel);
end
neuron=update_residual_custom_seeds(neuron,seed_all);

A_temp=neuron.A;
C_temp=neuron.C_raw;
for loop=1:10
    % estimate the background components
    neuron=update_background_CaliAli(neuron, use_parallel);
    neuron=update_spatial_CaliAli(neuron, use_parallel);
    neuron=update_temporal_CaliAli(neuron, use_parallel);
    dis=dissimilarity_previous(A_temp,neuron.A,C_temp,neuron.C_raw);
    A_temp=neuron.A;
    C_temp=neuron.C_raw;
    cprintf('-comment','Disimilarity with previous iteration is %.3f\n', dis);
    if dis<0.05
        break
    end
end

%% post-process the results automatically
neuron.remove_false_positives();

neuron=update_residual_Cn_PNR_batch(neuron);

%% Optional post-process
scale_to_noise(neuron);
neuron.C_raw=detrend_Ca_traces(neuron.sf*2,neuron.C_raw,get_batch_size(neuron));
neuron = postprocessDeconvolvedTraces(neuron, 'foopsi','ar2',-5);

%% Save results
neuron.orderROIs('snr');
save_workspace(neuron);


