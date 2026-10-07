%[text] # CaliAli demo pipeline
%[text] This demo illustrates how to process calcium imaging data. It simulates calcium imaging videos, which are saved in the current folder. You can play with the parameters 
%%
%[text] ## Demo data 1: Download the code to generate simulated videos (ETA: ~5 seconds)
out_dir = pwd;   % the simulated videos are saved here
sim_dir = fullfile(fileparts(which('Demo_pipeline')), 'Simulator');

if isempty(which('Simulate_Ca_video'))
    git_path = 'https://github.com/vergaloy/Simulate_Ca_Imaging_video/releases/download/v1.3/Simulate_Ca_Imaging_video_1.3.zip';
    zipFile = fullfile(tempdir, 'Simulate_Ca_Imaging_video.zip');
    websave(zipFile, git_path);         % Download the ZIP archive
    unzip(zipFile, sim_dir);            % Extract it next to this demo, in Demo/Simulator
    addpath(genpath(sim_dir));          % Add the extracted code to the MATLAB path
end
%[text] ## Demo data 2: Generate the simulated videos (ETA: ~3 minutes)
Simulate_Ca_video('Nneu', 100, 'ses', 4, ...
                'F', 500, 'across_session_translation', 5, ...
                'across_session_nonrigid',3,'scale',2, ...
                'within_session_translation_std', 3, ...
                'd',[440, 600],'save_GT', false, ...
                 'save_mat', false,'outpath',out_dir);
%%
%[text] # CaliAli demo pipeline
%[text] ## **Step 0: Load CaliAli parameters**
%[text] Modify `CaliAli\_demo\_parameters` to analyze your own data
CaliAli_options = CaliAli_demo_parameters();
%%
%[text] ## Step 1: Downsampling (ETA: ~1 minutes)
%[text] Select the simulated videos when the file picker opens.
CaliAli_options = CaliAli_downsample(CaliAli_options);
%%
%[text] ## Step 2: Motion Correction  (ETA: ~3-5 minutes)
CaliAli_options = CaliAli_motion_correction(CaliAli_options);
%%
%[text] ## Step 3: Align Sessions  (ETA: ~2-4 minutes)
CaliAli_options = CaliAli_align_sessions(CaliAli_options);

%[text]  🔹 **Note:** If analyzing only one session, run the following instead:
% CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options);
%%
%[text] ## Step 4: Evaluating Alignment Performance
%[text] Get BV-score:
fprintf('BV Score: %.4f\n', CaliAli_options.inter_session_alignment.BV_score);

% Get alignment metrics (Mean Correlation Score & Crispness - Higher is better)
Alignment_metrics = CaliAli_options.inter_session_alignment.alignment_metrics;
plot_alignment_scores(CaliAli_options);
drawnow;
%%
%[text] ## Step 5: Create Video of Aligned Projections
%[text] Extract and visualize the aligned projections
P = CaliAli_options.inter_session_alignment.P;
frame = plot_P(P); % Create a video of the projections
%%
%[text] ## Step 5 1/2: Check initialization parameters
%[text]  <u>***IMPORTANT***</u><u>**: Check the maximum number of neurons before extraction:**</u>
Check_initialization_parameters(CaliAli_options);
%[text] 🔹 **\*Optional (Recommended)**\*: Estimate CNMFe initialization parameters using the CaliAli App 
% CaliAli_set_initialization_parameters();
%%
%[text] ## Step 6: Run CNMF-E (ETA: ~3-5 minutes)
%[text] 🔹 Extract neurons:
File_path = CaliAli_cnmfe(); % Select "**_ds_mc_Aligned.mat"
%%
%[text] ## Step 7: Optional Post-Processing 
%[text] Load the neuron data
% load(File_path{end});

%[text]  🔹 Manually label components using the post-processing app
% ix = postprocessing_app(neuron, 0.6);

%[text]  🔹 Review or delete labeled components
% neuron.viewNeurons(find(ix), neuron.C_raw);  % View labeled components
% neuron.delete(ix);  % Delete unwanted components

%[text]  🔹 Manually merge neurons with less conservative parameters
% neuron.merge_high_corr(1, [0.3, 0.2, -inf]);

%[text]  🔹 Save the neuron data
% save_workspace(neuron);
%%
%[text] ## Step 8: Update Residuals (ETA: ~2-4 minutes)
% neuron = manually_update_residuals(neuron,0.6, 1);
%%
%[text] ## 🔹 Useful Commands
%[text] Visualize temporal traces
% view_traces(neuron);
%[text]  Save results in a new path (choose a new 'source\_extraction' folder)
% neuron = update_folder_path(neuron);
% cnmfe_path = neuron.save_workspace();



%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":17.6}
%---
