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

% Create batch list if batch_sz > 0
opt.input_files = create_batch_list(opt.input_files, opt.batch_sz,'_mc');


% Pre-allocate output files and get processing flags
[process_flags,out_pre] = pre_allocate_outputs(opt.input_files,'_mc');
try
    % Loop through each input file/batch for motion correction
    for k = 1:length(opt.input_files)
        if ~process_flags(k)
            fprintf(1, 'Skipping already processed batch %d\n', k);
            continue;
        end

        % Handle both string (original) and cell array (batch) inputs
        if ischar(opt.input_files{k})
            fullFileName = opt.input_files{k};
            fprintf(1, 'Now reading %s\n', fullFileName);
            intra_sess_tag= false;
        else
            fullFileName = opt.input_files{k}{1};
            fprintf(1, 'Processing batch from %s\n', fullFileName);
            if opt.input_files{k}{3}>1
                intra_sess_tag= true;
            else
                intra_sess_tag= false;
            end
        end

        % Generate output file name (same logic as original)
        [filepath, name] = fileparts(fullFileName);
        opt.output_file = strcat(filepath, filesep, name, '_mc', '.mat');
        out{k} = opt.output_file;


        % Load video data (handles both string and batch inputs)
        Y = CaliAli_load(opt.input_files{k}, 'Y');

        % Start parallel pool if not already running
        if isempty(gcp('nocreate'))
            parpool
        end
        disp('Calculating translation shift...')
        % Perform rigid motion correction
        if intra_sess_tag
            [Y, ref,template] = Rigid_mc(Y, opt,template);
        else
            [Y, ref,template] = Rigid_mc(Y, opt);
        end

        % Perform non-rigid motion correction if enabled
        if opt.do_non_rigid
            Y = Non_rigid_mc(Y, ref, opt);
        end

        % Interpolate dropped frames
        Y = interpolate_dropped_frames(Y);

        % Square the borders of the video
        if intra_sess_tag
            Y = apply_mask_square(Y, Mask);
            [Y,m] = square_borders(Y, 0);
            Mask(Mask>0)=m(Mask>0);
        else
            [Y,Mask] = square_borders(Y, 0);
        end
        opt.Mask=Mask;
        % Save motion-corrected video (handles both string and batch inputs)
        CaliAli_options.motion_correction = opt;
        CaliAli_save(opt.input_files{k}(:), Y, CaliAli_options);
    end

    % Store output file names in options structure
    CaliAli_options.motion_correction.output_files = unique(out);
    for i=1:length(CaliAli_options.motion_correction.output_files)
        apply_crop_on_disk(CaliAli_options.motion_correction.output_files{i});
    end

catch ME
    if exist(out_pre{1}, 'file') == 2
        remove_corrupted_output(out_pre);
    end
    fprintf(1, 'Motion correction failed: %s\n', ME.message);
    rethrow(ME);
end
end
