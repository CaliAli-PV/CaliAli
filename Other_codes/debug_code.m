mkdir('test');
cd('test');

%% Debug: normal (non-batch) processing
files = Simulate_Ca_video('ses', 3, 'outpath', pwd, 'F', 500);  % Simulate 3 sessions, 500 frames each, write to current dir
CaliAli_options = CaliAli_parameters('batch_sz', 0);            % Process everything in-memory (no batching)
CaliAli_options.downsampling.input_files = files;               % Convert files

CaliAli_options = CaliAli_downsample(CaliAli_options);          % Optional downsampling/preprocessing

CaliAli_options.motion_correction.input_files  = CaliAli_options.downsampling.output_files;  % Use downsampled outputs
CaliAli_options = CaliAli_motion_correction(CaliAli_options);   % Per-session motion correction
out = CaliAli_options.motion_correction.output_files;           % save outputs

% Compute projections/detrending for a single session only (useful for quick inspection)
CaliAli_options.inter_session_alignment.input_files = CaliAli_options.motion_correction.output_files;  
CaliAli_options.inter_session_alignment.input_files = CaliAli_options.inter_session_alignment.input_files{1};  % Pick first session
detrend_batch_and_calculate_projections(CaliAli_options);       % Generate mean/max projections, detrend, etc.

% Debug: inter-session alignment across all sessions
CaliAli_options.inter_session_alignment.input_files = out;       % Provide all motion-corrected sessions
CaliAli_options = CaliAli_align_sessions(CaliAli_options);       % Align sessions into a common reference space
runCNMFe(CaliAli_options.inter_session_alignment.out_aligned_sessions);  % Run CNMF-E on aligned sessions

%% Debug: batch processing (chunked workflow)

clear all
delete('*')

files = Simulate_Ca_video('ses', 3, 'outpath', pwd, 'F', 500);  % Simulate again for a clean run
CaliAli_options = CaliAli_parameters('batch_sz', 250);           % Enable batching (process 250 frames at a time)
CaliAli_options.downsampling.input_files = files;                % Input to downsampling stage

CaliAli_options = CaliAli_downsample(CaliAli_options);           % Downsampling with batch-aware settings (if applicable)

CaliAli_options.motion_correction.input_files  = CaliAli_options.downsampling.output_files;  % Feed into motion correction
CaliAli_options = CaliAli_motion_correction(CaliAli_options);   % Batch-aware motion correction
out = CaliAli_options.motion_correction.output_files;           % Corrected outputs (one per session)

% Compute projections/detrending for a single session (fast check)
CaliAli_options.inter_session_alignment.input_files = CaliAli_options.motion_correction.output_files;  
CaliAli_options.inter_session_alignment.input_files = CaliAli_options.inter_session_alignment.input_files{1};  % First session only
detrend_batch_and_calculate_projections(CaliAli_options);       % Projections useful for QA/alignment reference

% Debug: inter-session alignment after batch motion correction
CaliAli_options.inter_session_alignment.input_files = out;       % Use all sessions for alignment
CaliAli_options = CaliAli_align_sessions(CaliAli_options);       % Align all sessions
runCNMFe(CaliAli_options.inter_session_alignment.out_aligned_sessions);  % CNMF-E on aligned data

%% Debug: batch mode with memory monitoring

clear all
delete('*')

files = Simulate_Ca_video('ses', 1, 'outpath', pwd, 'F', 50000); % Stress test: single long session (50k frames)

CaliAli_options = CaliAli_parameters('batch_sz', 1000);          % Process in batches of 1000 frames
CaliAli_options.downsampling.input_files = files;                % Input to downsampling
CaliAli_options = CaliAli_downsample(CaliAli_options);           % Downsample (if configured)
CaliAli_options.motion_correction.input_files  = CaliAli_options.downsampling.output_files;  % To motion correction

% Run motion correction while logging memory usage
%   - First arg: function handle to run
%   - Second arg: retain only the most recent sample (1 output)
%   - Third arg: sampling frequency for monitoring (5 Hz)
[out, log_batch] = run_and_monitor_mem(@() CaliAli_motion_correction(CaliAli_options), 1, 5);

% Visualize memory usage over time during batch processing
figure;
plot(log_batch.t, log_batch.usedMB, 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Used memory (MB)');
title('Memory usage during batch motion correction');
legend('full','batch');     % If both traces are logged, they will appear here
grid on;