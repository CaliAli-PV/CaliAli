function CaliAli_options = CaliAli_motion_correction(varargin)
%% CaliAli_motion_correction: Perform rigid and non-rigid motion correction on video files.
%
% This function applies motion correction to a set of input video files. It performs both
% rigid and non-rigid motion correction, interpolates dropped frames, squares borders, and
% saves the corrected video as a .mat file.
%
% Inputs:
%   varargin - Variable input arguments, which are parsed into CaliAli_options.
%              The details of the CaliAli_options structure can be found in
%              CaliAli_demo_parameters().
%
% Outputs:
%   CaliAli_options - Updated structure containing the motion correction parameters.
%   Saved output files - Motion-corrected video files are saved as .mat files with
%                        the suffix "_mc" in the original file directory.
%
% Usage:
%   CaliAli_options = CaliAli_motion_correction();  % Interactive file selection
%   CaliAli_options = CaliAli_motion_correction(CaliAli_options);  % Using predefined options
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Load motion correction parameters
CaliAli_options = CaliAli_parameters(varargin{:});
opt = CaliAli_options.motion_correction;

% Select input files if not specified
if isempty(opt.input_files)
    opt.input_files = uipickfiles('FilterSpec', '*_ds*.mat');
end

% Generate batch list for processing
if opt.batch_sz > 0
    batch_list = create_batch_list(opt.input_files, opt.batch_sz);
    use_batching = true;
else
    batch_list = create_batch_list(opt.input_files, 0);  % No batching
    use_batching = false;
end

if use_batching
    % Setup output file for batched processing
    [filepath, ~] = fileparts(opt.input_files{1});
    opt.output_file = strcat(filepath, filesep, 'motion_corrected_concat.mat');
    
    % Initialize session frame counts for CaliAli_save_chunk
    unique_sessions = unique([batch_list{:,2}]);
    F = zeros(1, length(unique_sessions));
    for sess = unique_sessions
        sess_batches = batch_list([batch_list{:,2}] == sess, :);
        F(sess) = sess_batches{end,4}; % Last frame of last batch for this session
    end
    CaliAli_options.inter_session_alignment.F = F;
    CaliAli_options.inter_session_alignment.out_aligned_sessions = opt.output_file;
end

% Process each batch
for k = 1:size(batch_list, 1)
    batch_item = batch_list(k, :);
    fullFileName = batch_item{1};
    session_id = batch_item{2};
    start_frame = batch_item{3}; 
    end_frame = batch_item{4};
    
    fprintf(1, 'Processing %s frames %d-%d (session %d)\n', ...
            fullFileName, start_frame, end_frame, session_id);

    if ~use_batching
        % Traditional processing - one file per output
        [filepath, name] = fileparts(fullFileName);
        opt.output_file = strcat(filepath, filesep, name, '_mc', '.mat');
        
        if isfile(opt.output_file)
            fprintf(1, 'File %s already exists!\n', opt.output_file);
            continue;
        end
        
        % Load entire file
        Y = CaliAli_load(fullFileName, 'Y');
    else
        % Batched processing - check if final output exists
        if k == 1 && isfile(opt.output_file)
            fprintf(1, 'Batched output file %s already exists!\n', opt.output_file);
            break;
        end
        
        % Load frame range
        Y = CaliAli_load(fullFileName, 'Y', [start_frame, end_frame]);
    end

    % Start parallel pool if not already running
    if isempty(gcp('nocreate'))
        parpool
    end
    disp('Calculating translation shift...')
    % Perform rigid motion correction
    [Y, ref] = Rigid_mc(Y, opt);

    % Perform non-rigid motion correction if enabled
    if opt.do_non_rigid
        Y = Non_rigid_mc(Y, ref, opt);
    end

    % Interpolate dropped frames
    Y = interpolate_dropped_frames(Y);

    % Square the borders of the video
    Y = square_borders(Y, 0);

    % Save results
    if use_batching
        CaliAli_save_chunk(CaliAli_options, Y, session_id);
    else
        CaliAli_options.motion_correction = opt;
        CaliAli_save(opt.output_file(:), Y, CaliAli_options);
        out{session_id} = opt.output_file;
    end
end

if use_batching
    out = {opt.output_file};  % Single concatenated output file
else
    % Store output file names in options structure
    CaliAli_options.motion_correction.output_files = out;
end
end
