function [Y, p, R, CaliAli_options] = get_projections_and_detrend(Y, CaliAli_options)
% GET_PROJECTIONS_AND_DETREND Processes and detrends the session data, computes projections for various structures (e.g., neurons, blood vessels),
%   and returns the results along with updated options.
%
%   Input:
%       Y              - The session data (video frames) to be processed.
%       CaliAli_options - A structure containing the configuration options, including preprocessing steps.
%
%   Output:
%       Y              - The processed (detrended) session data.
%       p              - A table containing various projections (mean, blood vessels, neurons, etc.).
%       R              - The range of the data after detrending.
%       CaliAli_options - The updated configuration structure after processing.

% Store the original class of Y for later use (used to handle different data types)
S = class(Y);

% Remove borders from the data and obtain the binary mask for valid regions
[Y, CaliAli_options.Mask] = remove_borders(Y, 0);

% Calculate the median of the session data along the third dimension (frame dimension)
M = median(Y, 3);

% Get the blood vessel projections from the median frame
BV = CaliAli_get_blood_vessels(M, CaliAli_options);

% Remove background noise from the session data
Y = CaliAli_remove_background(Y, CaliAli_options);

% If specified, remove blood vessels from the neuron-filtered projections
if CaliAli_options.preprocessing.remove_BV
    Y = remove_BV(Y, BV); % Remove blood vessel projections from Y
end

% Choose the appropriate method for computing the projections based on the structure type
if strcmp(CaliAli_options.preprocessing.structure, 'dendrite')
    [Cn, PNR] = get_PNR_Cn_dendrite(Y, CaliAli_options); % Use dendrite method for projections
elseif CaliAli_options.preprocessing.fastPNR
    [Cn, PNR] = get_PNR_Cn_fast(Y); % Use fast PNR method for projections
else
    % Default: use greedy approach for calculating projections (with optional neuron enhancement)
    [~, Cn, PNR] = get_PNR_coor_greedy_PV(Y, CaliAli_options.gSig, [], [], CaliAli_options.preprocessing.neuron_enhance);
end

% Apply median filtering to the projections if specified in the options
if ~isempty(CaliAli_options.preprocessing.median_filtering)
    Cn = medfilt2(Cn, CaliAli_options.preprocessing.median_filtering); % Apply median filter to Cn
    PNR = medfilt2(PNR, CaliAli_options.preprocessing.median_filtering); % Apply median filter to PNR
end

% Calculate the range of the session data (for normalization)
R = range(Y, 'all');

% Convert the data to the appropriate format (uint8 or uint16) based on the original class
if strcmp(S, 'uint8')
    Y = v2uint8(Y); % Convert to uint8 format if the original data was uint8
else
    Y = v2uint16(Y); % Convert to uint16 format for other data types
end

% Fuse the blood vessel projections with the neuron projections for visual comparison
X = imfuse(mat2gray(Cn), BV, 'Scaling', 'joint', 'ColorChannels', [1 2 0]);

% Create a table to store the various projections for visualization and analysis
p = {mat2gray(M), BV, Cn, PNR, X}; % Store the projections (mean, blood vessels, neurons, PNR, fused)
p = array2table(p, 'VariableNames', {'Mean', 'BloodVessels', 'Neurons', 'PNR', 'BV+Neurons'});

end


function Y = remove_BV(Y, BV)
% REMOVE_BV Removes the blood vessels from the session data by applying a mask.
%   This function uses the blood vessel projection (BV) to create a mask, which is then applied to the session data 
%   to remove the blood vessel contributions.
%
%   Input:
%       Y  - The session data (video frames) to be processed.
%       BV - The blood vessel projection to create the mask.
%
%   Output:
%       Y  - The session data with blood vessels removed.

% Create a mask based on the squared blood vessel projection (to enhance BV features)
mask = mat2gray(BV.^2); % Square the BV to highlight the vessels
mask = (1 - double(mask)); % Invert the mask to get non-BV regions
mask = mask.^10; % Apply a power of 10 to sharpen the mask

% Apply the mask to the session data (remove blood vessels)
Y = double(Y) .* mask; % Element-wise multiplication removes BV areas
end
