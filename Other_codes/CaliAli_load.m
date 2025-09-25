function data = CaliAli_load(filename_or_batch, varname, frame_range)
%% CaliAli_load: Load a specific variable or all variables from a .mat file.
%
% Inputs:
%   filename_or_batch - Either:
%                      - String specifying the .mat file to load (original behavior)
%                      - Cell array {filename, session_id, start_frame, end_frame, output_filename} (batch behavior)
%   varname          - (Optional) Name of the variable to load. Supports dot notation
%                      for nested structures (e.g., 'Struct.elem1'). If not provided,
%                      all variables are loaded.
%   frame_range      - (Optional) 2-element vector [start_frame, end_frame] for loading
%                      specific frame ranges of the 'Y' variable only.
%
% Outputs:
%   data - Loaded variable or a structure containing all variables.
%
% Usage:
%   data = CaliAli_load('data.mat');              % Load all variables
%   var  = CaliAli_load('data.mat', 'varname');   % Load a specific variable
%   elem = CaliAli_load('data.mat', 'Struct.elem1'); % Load nested structure element
%   Y_chunk = CaliAli_load('data.mat', 'Y', [1, 1000]); % Load frames 1-1000 of Y
%   Y_batch = CaliAli_load({filename, sid, start, end, out}, 'Y'); % Load batch
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025


if nargin == 0
    error('Filename is required.');
end

% Handle batch input format
if iscell(filename_or_batch)
    % Batch format: {filename, session_id, start_frame, end_frame, output_filename}
    batch_info = filename_or_batch;
    filename = batch_info{1};
    start_frame = batch_info{3};
    end_frame = batch_info{4};
    
    % For batch processing, we always load the specified frame range
    if nargin >= 2 && strcmp(varname, 'Y')
        % Load specific frame range using matfile indexing
        m = matfile(filename);
        data = m.Y(:, :, start_frame:end_frame);
        return;
    else
        % For other variables, load normally but issue warning
        filename = batch_info{1};
        if nargin >= 2
            warning('Batch processing with frame range only supported for Y variable, loading full variable');
        end
    end
else
    % Original format: string filename
    filename = filename_or_batch;
end

% Check if filename has .mat extension
if ~endsWith(filename(:)', '.mat')
    filename = [filename '.mat'];
end

if nargin == 1
    % Load all variables if varname is not provided
    data = load(filename);
else
    % Load the specific variable (including nested structures)
    try
        % Split the varname by dots to handle nested structures
        parts = strsplit(varname, '.');

        % Load the top-level structure
        data = load(filename, parts{1});
        data = data.(parts{1});

        % Access nested elements
        for i = 2:numel(parts)
            data = data.(parts{i});
        end
    catch
        error('Invalid variable name or structure path.');
    end
end

% Handle frame range loading for 'Y' variable
if nargin == 3 && exist('frame_range', 'var') && ~isempty(frame_range)
    if strcmp(varname, 'Y') && length(frame_range) == 2
        % Load specific frame range using matfile indexing
        m = matfile(filename);
        data = m.Y(:, :, frame_range(1):frame_range(2));
    else
        warning('Frame range only supported for Y variable');
    end
end
end