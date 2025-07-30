%% Low-Memory Demo: Processing Multi-Session Data with Limited RAM

% This demo illustrates how to process calcium imaging data when there isn't 
% enough RAM to load an entire session into memory. 
%
% We will simulate 12 videos, 180 × 260 x 6,000 frames. The first 6 videos 
% will belong to one session, and the remaining 6 to another. 
%
% Processing each full session with the standard CaliAli pipeline would 
% require approximately 45 GB of RAM. However, this demo shows how to 
% process the data using only 16 GB of RAM. ETA are estimated with a 18 GB
% Macbook pro M3. 

%% Step 0: Pull the latest version of the low-memory CaliAli branch
% IMPORTANT: Be sure you're using the correct pipeline version:
% https://github.com/CaliAli-PV/CaliAli/tree/CaliAli_split_pipeline_low_memory

%% Step 1: Download the code to generate simulated videos (ETA: ~5 seconds)
path = 'https://github.com/vergaloy/Simulate_Ca_Imaging_video/releases/download/v1.1/Simulate_Ca_Imaging_video.zip';
zipFile = 'Simulate_Ca_Imaging_video.zip';
websave(zipFile, path);                  % Download the ZIP archive
outputFolder = pwd;
unzip(zipFile, outputFolder);            % Extract contents to current folder
addpath(genpath(outputFolder));          % Add all extracted code to the MATLAB path

%% Step 2: Generate the simulated videos (ETA: ~3 minutes)
Simulate_Ca_video('Nneu', 100, 'ses', 12, 'F', 6000, 'translation', 5, 'save_files', true);

%% Strategy for Low-Memory Systems:
% When you can't load all videos from a session into RAM:
%
% Split the session into multiple smaller video files and instruct CaliAli 
% to treat them as part of the same session. This ensures that:
% - Only one file is loaded at a time
% - Costly non-rigid alignment is applied **only across sessions**, not within
%
% This is achieved by setting the `same_ses_id` parameter.

CaliAli_options = CaliAli_demo_parameters();  % Load default CaliAli options
CaliAli_options.inter_session_alignment.same_ses_id = [1, 1, 1, 1, 1, 1, ...
                                                       2, 2, 2, 2, 2, 2];

%% Step 3: Convert video files to MATLAB format (ETA: ~1 minute)
CaliAli_options = CaliAli_downsample(CaliAli_options);

%% Step 4: Detrend, generate projections, and align sessions (ETA: ~11 minutes)
CaliAli_options = CaliAli_align_sessions(CaliAli_options);

%% Step 5: Extract neuron data (ETA: 30 minutes)
% Optional (but recommended): Use the CaliAli App to estimate good CNMF-E 
% initialization parameters before running extraction.
% CaliAli_set_initialization_parameters(CaliAli_options);

% Run CNMF-E extraction
File_path = CaliAli_cnmfe(); 