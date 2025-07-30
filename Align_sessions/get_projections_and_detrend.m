function [Y, p, R, CaliAli_options] = get_projections_and_detrend(Y, CaliAli_options)
%% get_projections_and_detrend: Process session data by detrending and computing projections.
%
% This function processes video session data by applying detrending, removing 
% background noise, and calculating projections such as blood vessels, 
% neuron activity, peak-to-noise ratio (PNR), and correlation images.
%
% Inputs:
%   Y               - Input video session data as a 3D array (height x width x frames).
%   CaliAli_options - Structure containing configuration options for processing.
%                     The details of this structure can be found in 
%                     CaliAli_demo_parameters().
%
% Outputs:
%   Y               - Detrended and background-corrected video data.
%   p               - Table containing projections: mean image, blood vessels,
%                     neuron projection, PNR, and a fused BV-neuron image.
%   R               - Data range after detrending, used for normalization.
%   CaliAli_options - Updated options structure after processing.
%
% Usage:
%   [Y, p, R, CaliAli_options] = get_projections_and_detrend(Y, CaliAli_options);
%
% Notes:
%   - Detrending removes slow intensity fluctuations.
%   - Blood vessels are extracted separately and can be removed from neuron projections.
%   - Projection methods vary depending on the structure type ('neuron' or
%   'dendrite'). Dendrites is currently work in progress
%   - Normalization is applied based on the calculated data range.
%   - A fused blood vessel-neuron image is generated for visualization.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

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

if CaliAli_options.preprocessing.fastPNR
    [Cn, PNR] = get_PNR_Cn_fast(Y); % Use fast PNR method for projections
% Choose the appropriate method for computing the projections based on the structure type
elseif strcmp(CaliAli_options.preprocessing.structure, 'dendrite')
    [Cn, PNR] = get_PNR_Cn_dendrite(Y, CaliAli_options); % Use dendrite method for projections
else
    % Default: use greedy approach for calculating projections (with optional neuron enhancement)
    fprintf('Calculating correlation image...\n');  
    [~, Cn, PNR] = get_PNR_coor_greedy_PV(Y, CaliAli_options.gSig, [], [], CaliAli_options.preprocessing.neuron_enhance);
end

% Apply median filtering to the projections if specified in the options
if ~isempty(CaliAli_options.preprocessing.median_filtering)
    Cn = medfilt2(Cn, CaliAli_options.preprocessing.median_filtering); % Apply median filter to Cn
    PNR = medfilt2(PNR, CaliAli_options.preprocessing.median_filtering); % Apply median filter to PNR
end

% Calculate the range of the session data (for normalization)
R = max(Y,[],'all');

% Convert the data to the appropriate format (uint8 or uint16) based on the original class
if strcmp(S, 'uint8')
    Y = uint8(Y./max(Y,[],'all')*256); % Convert to uint8 format if the original data was uint8
else
    Y = uint16(Y./max(Y,[],'all')*65536); % Convert to uint16 format for other data types
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
