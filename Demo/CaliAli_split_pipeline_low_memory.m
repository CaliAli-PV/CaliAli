%% Define CaliAli parameters as usual
CaliAli_options = CaliAli_demo_parameters();
CaliAli_options = CaliAli_downsample(CaliAli_options);

%% Split large video files into smaller segments (if needed)
% Useful when individual sessions are too large to fit in memory.
% Each segment is saved as a new .mat file with an incremented suffix (_b1, _b2, etc.).
max_frame = 3000;  % Maximum number of frames per batch
ses_id = CaliAli_divide_videos(max_frame);  % Returns session ID for each segment

%% Annotate which segments belong to the same session
% Example: for 4 files—2 from session A and 2 from session B—
% you would use: same_ses_id = [1, 1, 2, 2];
CaliAli_options.inter_session_alignment.same_ses_id = ses_id;

%% Optional: perform motion correction if needed
% CaliAli_options = CaliAli_motion_correction(CaliAli_options);

%% Align sessions (select the split _b# files)
CaliAli_options = CaliAli_align_sessions(CaliAli_options);

%% Extract calcium activity (CNMF-E)
File_path = CaliAli_cnmfe();