function S = separate_sessions(data, F, bin, sf)
% SEPARATE_SESSIONS Separates data into sessions based on frame information.
% Optionally, bins the data.
%
% INPUTS:
%   data: Matrix of data to be separated into sessions.
%
%   F: Number of frames in each session, as stored in
%      neuron.CaliAli_options.inter_session_alignment.F.
%      If not provided (or empty), the user will be prompted to select a CaliAli .mat
%      file (e.g. the _Aligned.mat file) or a workspace saved with
%      save_workspace, and F is read from its CaliAli_options.
%
%   bin: Bin size for binning the data. If set to 0, no binning is applied.
%
%   sf: Sampling frequency used when binning the data.
%
% OUTPUT:
%   S: Cell array containing separated session data.

% Check if 'bin' is provided, otherwise set it to 0
if ~exist('bin', 'var')
    bin = 0;
end

% Check if 'sf' is provided, otherwise set it to 1
if ~exist('sf', 'var')
    sf = 1;
end

% Ensure 'data' is a full matrix
data = full(data);

% Check if 'F' is provided, otherwise prompt user to select a file
if ~exist('F', 'var') || isempty(F)
    [file, path] = uigetfile('*.mat', 'Select a CaliAli .mat file or saved workspace');
    if isequal(file, 0)
        error('No file selected.');
    end
    F = load_session_frames(fullfile(path, file));
end

% Compute cumulative sum of frames and create intervals
c = cumsum(F);
c = c(:);
c = [[0; c(1:end-1)] + 1, c];

% Initialize cell array to store separated sessions
S = cell(1, size(c, 1));

% Loop through each interval and extract corresponding data
for i = 1:size(c, 1)
    temp = data(:, c(i, 1):c(i, 2));
    
    % If binning is specified, apply binning to the data
    if (bin > 0)
        temp = bin_data(temp, sf, bin);
    end
    
    % Store the separated session data in the cell array
    S{i} = temp;
end
end


function F = load_session_frames(file)
% LOAD_SESSION_FRAMES Reads the frames per session from a CaliAli .mat file
% (CaliAli_options) or from a workspace saved with save_workspace (neuron).
vars = who('-file', file);
if ismember('CaliAli_options', vars)
    opt = CaliAli_load(file, 'CaliAli_options');
elseif ismember('neuron', vars)
    neuron = CaliAli_load(file, 'neuron');
    opt = neuron.CaliAli_options;
elseif ismember('F', vars)
    % Files from older CaliAli versions kept F as a variable of its own
    opt.inter_session_alignment.F = CaliAli_load(file, 'F');
else
    opt = struct();
end

if isfield(opt, 'inter_session_alignment') && ...
        isfield(opt.inter_session_alignment, 'F') && ...
        ~isempty(opt.inter_session_alignment.F)
    F = opt.inter_session_alignment.F;
else
    error(['No frames per session found in %s. Select the _Aligned.mat file ' ...
        'or the workspace saved after CNMF-E, or pass F directly.'], file);
end
end
