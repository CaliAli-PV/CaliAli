function file_path=runCNMFe(in)
%% runCNMFe: Runs CNMF-E for source extraction from calcium imaging data.
%
% Inputs:
%   in - Path to the .mat file containing the imaging data and CNMF-E parameters.
%
% Outputs:
%   This function does not return an output but saves the extracted neuron components 
%
% Usage:
%   runCNMFe('path_to_mat_file.mat');
%
% Description:
%   - Loads CNMF-E parameters stored in the input file.
%   - Initializes CNMF-E with spatial and temporal components extracted from the video.
%   - Iteratively updates the spatial, temporal, and background components 
%     until convergence is reached based on a dissimilarity threshold (0.05).
%   - Performs automatic and manual merging of components based on spatial and 
%     temporal correlations.
%   - Updates residuals to refine extracted signals.
%   - Applies optional post-processing steps, including:
%       - False positive removal.
%       - Noise scaling and trace detrending.
%       - Ordering ROIs based on SNR.
%   - Saves the updated neuron structure for future analysis.
%
% Features:
%   - Iterative CNMF-E optimization with automated stopping criterion.
%   - Adaptive merging of highly correlated components.
%   - Integration with CaliAli preprocessing for improved residual analysis.
%   - Multiple visualization options for spatial and temporal components.
%
% Notes:
%   - The function uses several CNMF-E and CaliAli helper functions, including:
%     - `initComponents_parallel_PV`
%     - `CNMF_CaliAli_update`
%     - `update_residual_Cn_PNR_batch`
%     - `postprocessDeconvolvedTraces`
%     - `save_workspace`
%     - `viewNeurons`
%     - `show_contours`
%   - To manually inspect and classify neurons, use `postprocessing_app(neuron, 0.6)`.
%   - To visualize extracted traces, use `view_traces(neuron)`.
%
% Author: Pablo Vergara  
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025

neuron = Sources2D();
CaliAli_options=CaliAli_load(in,'CaliAli_options');
pars=CaliAli_options.cnmf;
neuron = fill_neuron(neuron, pars);
neuron.options = fill_neuron(neuron.options, pars);
neuron.CaliAli_options=CaliAli_options;

seed_all=get_seeds(neuron);
cprintf('*Magenta','%1.0f neurons will be initialized.\n', numel(seed_all));
pause(1) % so users dont miss this message. delete
neuron.select_data(in);
neuron.getReady();
evalin( 'base', 'clearvars -except parin theFiles' );
%% Load parameters stored in .mat file

%% initialize neurons from the video data
tic
cprintf('*blue','----------------Beginning neuron initialization----------------\n');
neuron =initComponents_parallel_PV(neuron,[],[], 0, 1,0);
toc
% neuron.show_contours(0.8, [], neuron.Cn, 0); %
save_workspace(neuron);
%% Update components
cprintf('*blue','----------------Beginning neuron refinement with CMNF----------------\n');
A_temp=neuron.A;
C_temp=neuron.C_raw;
for loop=1:10
    % estimate the background components
    neuron=CNMF_CaliAli_update('Background',neuron);
    neuron=CNMF_CaliAli_update('Spatial',neuron);
    neuron=CNMF_CaliAli_update('Temporal',neuron);
    %% post-process the results automatically
    neuron.remove_false_positives();
    neuron.merge_neurons_dist_corr(neuron.show_merge);
    neuron.merge_high_corr(neuron.show_merge,neuron.CaliAli_options.cnmf.merge_thr_spatial);
    neuron.merge_high_corr(neuron.show_merge, [0.9, -inf, -inf]);

    dis=dissimilarity_previous(A_temp,neuron.A,C_temp,neuron.C_raw);
    cprintf('-comment','Disimilarity with previous iteration is %.3f\n', dis);

    A_temp=neuron.A;
    C_temp=neuron.C_raw;

    if dis<0.05
        cprintf('*blue','CNMF has converged to an estable Solution\n');
        break
    end
end    %% save the workspace for future analysis
neuron=update_residual_Cn_PNR_batch(neuron);
save_workspace(neuron);



%% Optional post-process
cprintf('*blue','----------------Post-processing extracted traces----------------\n');
scale_to_noise(neuron);
neuron.C_raw=detrend_Ca_traces(neuron.sf*2,neuron.C_raw,get_batch_size(neuron));
neuron = postprocessDeconvolvedTraces(neuron, 'foopsi','ar2',-5);


%% Save results
neuron.orderROIs('snr');
file_path=save_workspace(neuron);

%% show neuron contours
fclose('all');
end

%% USEFULL COMMANDS
%  fclose('all');
% justdeconv(neuron,'thresholded','ar2');

%%  To manually inspect spatial and temporal components of each neuron
%   neuron.orderROIs('sparsity_spatial');   % order neurons in different ways {'snr', 'decay_time', 'mean', 'circularity','sparsity_spatial','sparsity_temporal','pnr'}
%   neuron.viewNeurons([], neuron.C_raw);
%   neuron.viewNeurons([10,13,20], neuron.C_raw);
%% To save results in a new path run these lines a choose the new 'source_extraction' folder:

% neuron=update_folder_path(neuron);

%   cnmfe_path = neuron.save_workspace();
%% To visualize neurons contours:
%   neuron.Coor=[]
%   neuron.show_contours(0.9, [], neuron.PNR, 0);  %PNR
%   neuron.show_contours(0.6, [], neuron.Cn,0);   %CORR
%   neuron.show_contours(0.9, [], neuron.Cn.*neuron.PNR,0); %PNR*CORR


%% normalized spatial components
% A=neuron.A;A=full(A./max(A,[],1)); A=reshape(max(A,[],2),[neuron.options.d1,neuron.options.d2]);
% neuron.show_contours(0.6, [], A,true);

%% to visualize temporal traces
%   figure;strips(neuron.C_raw');
%   figure;stackedplot(neuron.C_raw');
%   view_traces(neuron);

%% Optional post-process
% neuron.merge_high_corr(1, [0.3, 0.2, -inf]);


% ix=postprocessing_app(neuron,0.6);
% neuron.viewNeurons(find(ix), neuron.C_raw);
% neuron.delete(ix);
% save_workspace(neuron);
%% update residuals
% neuron.Coor=neuron.get_contours(0.6);
% neuron=manually_update_residuals(neuron,0.6,1);



















