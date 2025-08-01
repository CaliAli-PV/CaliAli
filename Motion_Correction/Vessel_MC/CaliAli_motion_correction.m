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

% Loop through each selected file for motion correction
for k = 1:length(opt.input_files)
    fullFileName = opt.input_files{k};
    fprintf(1, 'Now reading %s\n', fullFileName);

    % Generate output file name
    [filepath, name] = fileparts(fullFileName);
    opt.output_file = strcat(filepath, filesep, name, '_mc', '.mat');
    out{k} = opt.output_file;

    % Check if output file already exists
    if ~isfile(opt.output_file)
        % Load video data
        Y = CaliAli_load(fullFileName, 'Y');

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

        % Save motion-corrected video
        CaliAli_options.motion_correction = opt;
        CaliAli_save(opt.output_file(:), Y, CaliAli_options);
    else
        fprintf(1, 'File %s already exists!\n', opt.output_file);
    end

    % Store output file name in options structure
    CaliAli_options.motion_correction.output_files = out;
end
end
