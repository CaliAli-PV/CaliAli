function S = separate_sessions(data, F, bin, sf)
% SEPARATE_SESSIONS Separates data into sessions based on frame information.
% Optionally, bins the data.
%
% INPUTS:
%   data: Matrix of data to be separated into sessions.
%
%   F: Frame information used to define intervals for separating sessions.
%      If not provided, the user will be prompted to select a file.
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
if ~exist('F', 'var')
    [file, path] = uigetfile('*.mat');
    try
        load([path, file], 'F');
    catch
        fprintf(1, 'No frame data was detected in %s...\n', file);
    end
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
