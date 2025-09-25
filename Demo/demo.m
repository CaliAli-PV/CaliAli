%% CaliAli demo pipeline
%% *Step 0: Load CaliAli parameters*
% Modify `CaliAli_demo_parameters` to analyze your own data

CaliAli_options = CaliAli_demo_parameters();
%% Step 1: Downsampling

CaliAli_options = CaliAli_downsample(CaliAli_options);
%% Step 2: Motion Correction
% Note: You don’t need to run this with the demo files, as they are already 
% motion corrected.

CaliAli_options = CaliAli_motion_correction(CaliAli_options);
%% Step 3: Align Sessions

CaliAli_options = CaliAli_align_sessions(CaliAli_options);

%% 
% 🔹 *Note:* If analyzing only one session, run the following instead:

% CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options);
%% Step 4: Evaluating Alignment Performance
% Get BV-score:

fprintf('BV Score: %.4f\n', CaliAli_options.inter_session_alignment.BV_score);

% Get alignment metrics (Mean Correlation Score & Crispness - Higher is better)
Alignment_metrics = CaliAli_options.inter_session_alignment.alignment_metrics;
plot_alignment_scores(CaliAli_options);
drawnow;
%% Step 5: Create Video of Aligned Projections
% Extract and visualize the aligned projections

P = CaliAli_options.inter_session_alignment.P;
frame = plot_P(P); % Create a video of the projections
%% Step 6: Run CNMF-E
% 🔹 **Optionional (Recommended)**: Estimate CNMFe initialization parameters 
% using the CaliAli App 

% CaliAli_set_initialization_parameters(CaliAli_options);
%% 
% 🔹 Extract neurons:

File_path = CaliAli_cnmfe(); % Select "250207_191126_ses03_mc_ds_Aligned.mat"
%% Step 7: Optional Post-Processing 
% Load the neuron data

% load(File_path{end});

%% 
% 🔹 Manually label components using the post-processing app

% ix = postprocessing_app(neuron, 0.6);

%% 
% 🔹 Review or delete labeled components

% neuron.viewNeurons(find(ix), neuron.C_raw);  % View labeled components
% neuron.delete(ix);  % Delete unwanted components

%% 
% 🔹 Manually merge neurons with less conservative parameters

% neuron.merge_high_corr(1, [0.3, 0.2, -inf]);

%% 
% 🔹 Save the neuron data

% save_workspace(neuron);
%% Step 8: Update Residuals

% neuron = manually_update_residuals(neuron,0.6, 1);
%% 🔹 Useful Commands
% Visualize temporal traces

% view_traces(neuron);
%% 
% Save results in a new path (choose a new 'source_extraction' folder)

neuron = update_folder_path(neuron);
cnmfe_path = neuron.save_workspace();