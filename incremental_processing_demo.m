% This script demonstrates the strategy used for incremental extraction.
%
% Example:
% Sessions 1, 2, and 3 have already been aligned and extracted.
% We now want to incrementally analyze sessions 4 and 5 without rerunning
% the full extraction pipeline.

%% Step 1: Simulate the data

files = Simulate_Ca_video( ...
    'Nneu', 100, ...
    'ses', 5, ...
    'F', 500, ...
    'translation_misalignment', 5, ...
    'session_motion_std', 0, ...
    'NR_misalignment', 3, ...
    'scale', 2, ...
    'd', [440, 600], ...
    'save_GT', false, ...
    'save_mat', false);

%% Step 2: Downsample all sessions

CaliAli_options = CaliAli_demo_parameters();
CaliAli_options.downsampling.input_files = files;
CaliAli_options = CaliAli_downsample_batch(CaliAli_options);

ds_output = CaliAli_options.downsampling.output_files;

%% Step 3: Align only sessions 1-3

CaliAli_options.inter_session_alignment.input_files = ds_output(1, 1:3);
CaliAli_options = CaliAli_align_sessions(CaliAli_options);

aligned_1_3 = CaliAli_options.inter_session_alignment.out_aligned_sessions;

%% Step 4: Extract activity from sessions 1-3

source_extraction_files = CaliAli_cnmfe(aligned_1_3);

%% Step 5: Prepare incremental alignment for sessions 4 and 5
%
% Input structure:
%   {aligned sessions 1-3, session 4, session 5}
%
% CaliAli detects the "Aligned" tag in the first input file and
% automatically switches to incremental alignment mode.

incremental_files = {
    aligned_1_3, ...
    ds_output{1, 4}, ...
    ds_output{1, 5}
};

%% Step 6: Incrementally align sessions 4 and 5 to sessions 1-3

CaliAli_options.inter_session_alignment.input_files = incremental_files;
CaliAli_options = CaliAli_align_sessions(CaliAli_options);

aligned_1_5 = CaliAli_options.inter_session_alignment.out_aligned_sessions;

%% Step 7: Propagate the extraction from sessions 1-3 to sessions 4-5

newFile = aligned_1_5;
sourceFile = source_extraction_files{1};

neuron = propagate_spatials(newFile, sourceFile);

save_workspace(neuron);

%% Step 8: Check for missing residuals in the newly added sessions
%
% The fast residual option only updates the newly added ROIs.

neuron = manually_update_residuals(neuron, 0.6, 1, false);

save_workspace(neuron);