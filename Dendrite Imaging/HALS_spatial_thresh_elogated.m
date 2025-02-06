function A = HALS_spatial_thresh_elogated(Y, A, C, active_pixel,d1,d2, maxIter, sn, elongation_factor)

 % temp = HALS_spatial_thresh_elogated(Ypatch, A_patch, C_patch, IND_patch,nr,nc, 3, sn_patch,1.1);
%% HALS_spatial_thresh: Update spatial components (A) in CNMF-E using HALS.
% 
%   This function updates the spatial components (A) in CNMF-E while keeping 
%   the temporal components (C) fixed. It uses the Hierarchical Alternating 
%   Least Squares (HALS) algorithm and incorporates a thresholding step 
%   based on the noise level. Additionally, it includes a mechanism to 
%   promote the elongation of spatial components, which can be beneficial 
%   for capturing elongated structures like dendrites.
%
%   Inputs:
%       Y:                Fluorescence data (d x T matrix, where d is the 
%                         number of pixels and T is the number of time points).
%       A:                Spatial components (d x K matrix, where K is the 
%                         number of components).
%       C:                Temporal components (K x T matrix).
%       active_pixel:     Mask for pixels to be updated (logical array of 
%                         size d).
%       maxIter:          Maximum number of HALS iterations.
%       sn:               Noise level estimate for each pixel (d x 1 vector).
%       elongation_factor: Factor to control the degree of elongation 
%                         (e.g., 1.2 for 20% elongation).
%
%   Output:
%       A:                Updated spatial components (d x K matrix).
%
%   Author: 
%       Pengcheng Zhou, Carnegie Mellon University
%
%   Adapted from: 
%       Johannes Friedrich's NIPS paper "Fast Constrained Non-negative Matrix 
%       Factorization for Whole-Brain Calcium Imaging Data"


%% Set default values for optional inputs
if nargin < 7
    elongation_factor = 1.1;    % Default elongation factor
end
if nargin < 6
    maxIter = 1;                % Default maximum iteration number
end
if nargin < 4
    active_pixel = true(size(A)); % Default: update all pixels
elseif isempty(active_pixel)
    active_pixel = true(size(A)); 
else
    active_pixel = logical(active_pixel); 
end

% Estimate noise level if not provided
if ~exist('sn', 'var') || isempty(sn)
    sn = GetSn(Y); 
end
sn = reshape(sn, [], 1); 

%% Initialization
A(~active_pixel) = 0;            % Set inactive pixels to 0
K = size(A, 2);                  % Number of components
Cmean = mean(C, 2);              % Mean of temporal components
Ymean = mean(Y, 2);              % Mean of fluorescence data
T = size(C, 2);                  % Number of time points
U = double(Y*C' - T*(Ymean*Cmean')); % Pre-computed matrix for update
V = double(C*C' - T*(Cmean*Cmean')); % Pre-computed matrix for update
cc = diag(V);                    % Squares of L2 norms of all components
cc_thr = 3.0 ./ sqrt(cc);        % Threshold for component update

% Get image dimensions from the first spatial component

%% HALS update loop
for miter = 1:maxIter
    for k = 1:K
        if cc(k) == 0
            continue;  % Skip if component has zero norm
        end

        tmp_ind = active_pixel(:, k);  % Pixels to update for component k

        if sum(tmp_ind) == 0
            A(:, k) = 0;  % Set component to zero if no active pixels
            continue; 
        end

        % HALS update rule
        ak = A(tmp_ind, k) + (U(tmp_ind, k) - A(tmp_ind, :)*V(:, k)) / cc(k); 
        ak(ak < sn(tmp_ind) * cc_thr(k)) = 0;  % Thresholding based on noise level
        A(tmp_ind, k) = ak;  % Update spatial component
    end

    % Promote elongation after each iteration
    A = promoteElongation(A, d1, d2, elongation_factor); 
end

end

function A_updated = promoteElongation(A, d1, d2, elongation_factor)
%promoteElongation  Scales spatial components in CNMF-E to promote 
%                   elongation.
%
%   A_updated = promoteElongation(A, d1, d2, elongation_factor)
%
%   Inputs:
%       A:                Spatial component matrix from CNMF-E.
%       d1:               Number of rows in the original image.
%       d2:               Number of columns in the original image.
%       elongation_factor: Factor to control the degree of elongation 
%                         (e.g., 1.2 for 20% elongation).
%
%   Output:
%       A_updated:  Updated spatial component matrix with promoted elongation.

% Reshape spatial components to image dimensions
A_reshaped = reshape(full(A), d1, d2, []);

% Initialize the updated spatial components
A_updated = zeros(size(A));

for i = 1:size(A, 2)  % Loop through each component
    component = A_reshaped(:, :, i);

    % Calculate the centroid of the component
    [rows, cols] = find(component);
    centroid_row = round(mean(rows));
    centroid_col = round(mean(cols));

    % Create a linear index map
    [X, Y] = meshgrid(1:d2, 1:d1);
    distances = sqrt((X - centroid_col).^2 + (Y - centroid_row).^2);

    % Create an elongation mask (stronger along a preferred axis)
    elongation_mask = exp(-distances ./ (elongation_factor * max(distances(:)))); 

    % Scale the component with the elongation mask
    scaled_component = component .* elongation_mask;

    % Reshape back to vector and store in A_updated
    A_updated(:, i) = scaled_component(:);
end

end