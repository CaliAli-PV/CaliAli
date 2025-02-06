%% Load the demo parameters. 
CaliAli_options=CaliAli_demo_parameters(); % <-- Modifiy this function to analyze your own data.

%% Do downsampling:
CaliAli_options=CaliAli_downsample(CaliAli_options);  

%% Do motion correction
CaliAli_options=CaliAli_motion_correction(CaliAli_options); % You don't need to run this with the Demo files as they are already motion corrected.

%% Align session　　
CaliAli_align_sessions(CaliAli_options);

% **Note**:If only one session require to be analyzed run instead of CaliAli_align_sessions(CaliAli_options);
% detrend_batch_and_calculate_projections(CaliAli_options);

%% Evaluating alignment performance

CaliAli_options = CaliAli_load('v4_mc_ds_Aligned.mat','CaliAli_options');  % Replace 'v4_mc_ds_Aligned.mat' with the path to your file.

% Get BV-score:
fprintf('BV Score: %.4f\n', CaliAli_options.inter_session_alignment.BV_score);
% Get alignment metrics: Mean Correlation score and Crispness (Higher the
% better)
Alignment_metrics = CaliAli_options.inter_session_alignment.alignment_metrics
plot_alignment_scores(CaliAli_options)

% View aligned projections:
P = CaliAli_options.inter_session_alignment.P;  %extract the aligned projections
frame=plot_P(P); %Create video of the projections.

%% Run CNMF-E

% Estiamte CNMFe initialization parameters using CaliAli app before neuronal extraction (Recomended):
% CaliAli_set_initialization_parameters(CaliAli_options)

% Or directly extract neurons used the pre-defined parameters
CaliAli_cnmfe()


%% Optional post-process (Run this after loading the nueron object produced by CNMF-E
%Manually abel component with post-processing app:
ix=postprocessing_app(neuron,0.6);

% Review labeled components:
% neuron.viewNeurons(find(ix), neuron.C_raw);
% Or delete them:
% neuron.delete(ix);

%Manually merge neuron with less conservative parameters
% neuron.merge_high_corr(1, [0.3, 0.2, -inf]);

% Save the neuron data:
% save_workspace(neuron);
 
%% update residuals
% neuron=manually_update_residuals(neuron,use_parallel);

%% USEFULL COMMANDS
%% to visualize temporal traces
%   view_traces(neuron);

%% To save results in a new path run these lines a choose the new 'source_extraction' folder:
%   neuron=update_folder_path(neuron);
%   cnmfe_path = neuron.save_workspace();






