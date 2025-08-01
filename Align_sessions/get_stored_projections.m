function T = get_stored_projections(CaliAli_options)
%% get_stored_projections: Retrieve and combine stored projections from session files.
%
% Inputs:
%   CaliAli_options - Structure containing configuration options, including 
%                     session file paths. Details can be found in 
%                     CaliAli_demo_parameters().
%
% Outputs:
%   T - Table containing the combined projections from all session files.
%
% Usage:
%   T = get_stored_projections(CaliAli_options);
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Extract the configuration options related to inter-session alignment
opt = CaliAli_options.inter_session_alignment;

% Initialize an empty table for storing the projections
T = table;

% Loop through each session file and load the projections
for k = 1:size(opt.output_files, 2)
    % Load the current session's projection data
    fullFileName = opt.output_files{k};
    temp = CaliAli_load(fullFileName, 'CaliAli_options.inter_session_alignment');
    
    % Concatenate the projections from the current session to the table T
    T = cat_table(T, temp.P);
end

% Scale the projections to visualize them properly
T = scale_Cn(T);

end

%%=======================================
function T = cat_table(T, P)
% CAT_TABLE Concatenates projections into a table.
%   This function combines projections from different sessions (P) into a single table (T) 
%   by concatenating along the appropriate dimension.
%
%   Input:
%       T - The current table containing projections.
%       P - The new projections to be added to the table.
%
%   Output:
%       T - The updated table containing the concatenated projections.

% If the table is empty, initialize it with the first set of projections
if isempty(T)
    T = P;
else
    % Loop through each column of the projections in P and concatenate them
    for i = 1:size(P, 2)
        % Concatenate the projections along the appropriate dimension (based on the number of dimensions)
        T.(i){1, 1} = single(cat(ndims(P.(i){1, 1}) + 1, T.(i){1, 1}, P.(i){1, 1}));
    end
end

end

%%=======================================
function P = scale_Cn(P)
% SCALE_Cn Scales the projections to a uint8 format with joint scaling for comparison.
%   This function takes the projections and scales them to a uint8 format while preserving relative intensities.
%   The resulting projections are fused for visual comparison.
%
%   Input:
%       P - The projections data.
%
%   Output:
%       P - The updated projections with scaled and fused visual comparison data.

% Convert the C (neuron/BV) projection to a range of [0, 1] for proper scaling
C = mat2gray(P.(3){1, 1});

% Convert the reference projection (BV or Neuron) to a range of [0, 1] for proper scaling
Vf = mat2gray(P.(2){1, 1});

% Fuse the projections and the reference using joint scaling and color channels
for k = 1:size(C, 3)
    % Fuse the C and reference projections, setting the color channels for visualization
    X(:,:,:,k) = imfuse(C(:,:,k), Vf(:,:,k), 'Scaling', 'joint', 'ColorChannels', [1 2 0]);
end

% Store the fused projections in the fifth field of P for visualization purposes
P.(5){1, 1} = X;

end
