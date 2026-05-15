function neuron=manually_update_residuals(neuron,thr,use_parallel,update_temporal)
%% manually_update_residuals: Iteratively refines residuals in CNMF-E extracted components.
%
% Inputs:
%   neuron       - CNMF-E extracted neuron structure containing spatial (A) and
%                  temporal (C_raw) components.
%   use_parallel - Boolean flag to enable parallel computation for speed-up.
%   thr          - Threshold for countours drawing
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
    update_temporal=True;
end

neuron.Coor=neuron.get_contours(thr);
seed_all=get_seed(neuron);
if update_temporal
neuron=update_temporal_CaliAli(neuron, use_parallel);
end
if neuron.fast_residual
    ret_id=1:size(neuron.A,2);
else
    ret_id=[];
end

neuron=update_residual_custom_seeds(neuron,seed_all);

A_temp=neuron.A;
C_temp=neuron.C_raw;

for loop=1:10
    % estimate the background components
    neuron=update_background_CaliAli(neuron, use_parallel,ret_id);
    neuron=update_spatial_CaliAli(neuron, use_parallel,ret_id);
    neuron=update_temporal_CaliAli(neuron, use_parallel,ret_id);
    A_temp=neuron.A;
    C_temp=neuron.C_raw;
    [dis,sim_scores]=dissimilarity_previous(A_temp,neuron.A,C_temp,neuron.C_raw);
    if neuron.retreat_neurons
        ret_id=sim_scores>0.9;
        cprintf('-comment','%1.0f stable neurons will be retreated in the next iteration.\n', sum(ret_id));
        dis=1-mean(sim_scores(~ret_id),'omitmissing');
        if isnan(dis)
            dis=0;
        end
    end
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


