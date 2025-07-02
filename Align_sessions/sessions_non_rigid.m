function [P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options, neurons_only)
%% sessions_non_rigid: Perform non-rigid alignment for session data.
%
% Inputs:
%   P               - Cell array containing the session projections.
%   CaliAli_options - Structure containing configuration options for alignment.
%                     Details can be found in CaliAli_demo_parameters().
%   neurons_only    - (Optional) Boolean flag indicating whether to align only neuron data. Default is false.
%
% Outputs:
%   P               - Updated cell array with applied non-rigid shifts.
%   CaliAli_options - Updated structure with computed non-rigid transformations.
%
% Usage:
%   [P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options);
%   [P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options, true); % Align neurons only
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% If "neurons_only" is not provided, set it to false
if ~exist('neurons_only','var')
    neurons_only = false;
end

% If alignment is disabled, initialize empty shift data and return early
if ~CaliAli_options.inter_session_alignment.do_alignment_non_rigid || isscalar(unique(CaliAli_options.inter_session_alignment.same_ses_id))
    [d1,d2,d3] = size(P.(1){1,1});
    if neurons_only
        CaliAli_options.inter_session_alignment.shifts_n = zeros(d1,d2,2,d3);
        CaliAli_options.inter_session_alignment.NR_Mask_n = true(d1,d2);
    else
        CaliAli_options.inter_session_alignment.shifts = zeros(d1,d2,2,d3);
        CaliAli_options.inter_session_alignment.NR_Mask = true(d1,d2);
    end
    return
end

P=average_P_same_sessions(P,CaliAli_options.inter_session_alignment.same_ses_id);

fprintf(1, 'Calculating non-rigid alignments...\n');

% Pre-allocate data for parallel computation
[Proj,b,P] = pre_allocate_projections(P, CaliAli_options, neurons_only);

% Get transformation matrix, local weights, and global weights
[T, locW, globW] = get_matrices(Proj, b);
globW = globW ./ sum(globW); % Normalize global weights

% Convert weights to 4D array for matrix operations
locW = reshape(locW, [size(locW, 1), size(locW, 2), 1, size(locW, 3)]);
locW = cat(3, locW, locW);
for i = 1:length(globW)
    W(:,:,:,i) = locW(:,:,:,i) .* globW(i);
end
W = W ./ sum(W, 4); % Normalize the weights

% Calculate weighted transformations (shifts) for non-rigid alignment
for i = 1:size(T, 1)
    t = cat(4, T{i, :});
    t = t .* W;  % Apply weights to transformations
    shifts(:,:,:,i) = sum(t, 4); % Compute total shift
end

% Set NaN values in shifts to 0 and center shifts
shifts(isnan(shifts)) = 0;
shifts = shifts - mean(shifts, 4);

% Apply the calculated shifts to the projections (P)
for k = 1:size(P, 2)
    temp = double(cell2mat(P{1, k}));
    parfor i = 1:size(shifts, 4)
        temp(:,:,i) = imwarp(temp(:,:,i), shifts(:,:,:,i), 'FillValues', nan); % Apply non-rigid shift to each projection
    end
    P{1, k} = {temp};  % Store the shifted projection
end

% Remove black borders from projections after alignment
Mask = 1 - max(isnan(P.(k){1, 1}), [], 3);  % Create mask to identify non-NaN areas
[~, Mask] = remove_borders(Mask, 0);  % Remove borders from the mask
for k = 1:size(P, 2)
    temp = P.(k){1, 1};
    P.(k){1, 1} = remove_borders(temp);  % Remove borders from each projection
end

[P,shifts]=expand_P_from_same_session_batches(P,shifts,CaliAli_options.inter_session_alignment.same_ses_id);

% Update the CaliAli_options structure with the computed shifts and masks
if neurons_only
    CaliAli_options.inter_session_alignment.shifts_n = shifts;
    CaliAli_options.inter_session_alignment.NR_Mask_n = Mask;
else
    CaliAli_options.inter_session_alignment.shifts = shifts;
    CaliAli_options.inter_session_alignment.NR_Mask = Mask;
end

end


%% NESTED FUNCTIONS

function [Proj, b, P] = pre_allocate_projections(P, CaliAli_options, neurons_only)
% PRE_ALLOCATE_PROJECTIONS Prepares the projections data for parallel computation and processes the projections.
%   This function organizes the projections data, applies adaptive histogram equalization, and prepares
%   the projections for the alignment process.
%
%   Input:
%       P              - A cell array containing the projections data.
%       CaliAli_options - A structure containing configuration options, including the projections to be used.
%       neurons_only    - A flag indicating whether to only align neurons (default is false).
%
%   Output:
%       Proj           - The projections data for alignment, pre-processed and organized.
%       b              - Pairwise combinations of projections for alignment.
%       P              - The processed projections data, including fused projections.

% Convert the mean frame (first projection) to uint8 format
Mb = v2uint8(cell2mat(P{1, 1}));  % Mean frame
Vf = v2uint8(cell2mat(P{1, 2}));  % Blood vessels

% Convert the neuron projection and the PNR (signal-to-noise ratio) data
Cn = cell2mat(P{1, 3});
PNR = cell2mat(P{1, 4});

% Apply adaptive histogram equalization to the neuron projections
Cn = v2uint8(mat2gray(PNR) .* mat2gray(Cn).^2);  % Enhance contrast by multiplying with normalized PNR
for i = 1:size(Cn, 3)
    Cn(:,:,i) = adapthisteq(Cn(:,:,i));  % Apply adaptive histogram equalization to each frame
end

% If projections do not include blood vessels or if only neurons should be aligned,
% set the blood vessel data (Vf) to be the same as neurons (Cn).
if ~contains(CaliAli_options.inter_session_alignment.projections, 'BV') || neurons_only
    Vf = Cn;
end

% If projections do not include neurons, use blood vessels as the reference
if ~contains(CaliAli_options.inter_session_alignment.projections, 'neuron')
    Cn = Vf;
end

% Fuse the projections (Vf and Cn) and apply median filtering for smoothing
for i = 1:size(Cn, 3)
    X(:,:,i) = mat2gray(max(cat(3, Vf(:,:,i), medfilt2(Cn(:,:,i))), [], 3));  % Fused projection using max and median
end
X = v2uint8(X);  % Convert the fused projection to uint8 format

% Store the fused projections in the fifth field of P
P.(5){1, 1} = mat2gray(X);

% Combine all the projections into a 4D matrix for processing
Proj_t = permute(cat(4, Mb, Cn, X, Vf, Vf), [1, 2, 4, 3]);  % Arrange the data in 4D for alignment
[d1, d2, d3, d4] = size(Proj_t);  % Get the dimensions of the 4D array

% Split the 4D array into a cell array for parallel computation
Proj_t = squeeze(mat2cell(Proj_t, d1, d2, d3, ones(1, d4)));

% Calculate all pairwise combinations of projections for alignment
b = nchoosek(1:d4, 2);  % Generate all combinations of projections
for i = 1:size(b, 1)
    Proj{i, 1} = Proj_t{b(i, 1)};  % Get the first projection in the pair
    Proj{i, 2} = Proj_t{b(i, 2)};  % Get the second projection in the pair
end

% Clean up the temporary variable used for organizing projections
clear Proj_t;

end

function [T, loc_c, glob_c] = get_matrices(Proj, b)
% GET_MATRICES Computes the transformation matrices, local and global weights for each projection pair.
%   This function calculates transformation matrices and weights needed for non-rigid alignment.
%
%   Input:
%       Proj - The projection data (pre-processed).
%       b    - Pairwise combinations of projections for alignment.
%
%   Output:
%       T    - Transformation matrices for each pair of projections.
%       loc_c - Local similarity measures for each pair.
%       glob_c - Global similarity measures for each pair.

% Pre-allocate variables for storing the transformation matrices and weights
T = cell(size(b, 1), 1);  % Forward transformation matrices
loc_c = cell(size(b, 1), 1);  % Local similarity for forward transformations
glob_c = zeros(size(b, 1), 1);  % Global similarity for forward transformations

Tb = cell(size(b, 1), 1);  % Backward transformation matrices
loc_cb = cell(size(b, 1), 1);  % Local similarity for backward transformations
glob_cb = zeros(size(b, 1), 1);  % Global similarity for backward transformations

% Parallel loop to compute transformations for each pair of projections
parfor i = 1:size(b, 1)
    img = Proj(i, :);  % Get the pair of projections for the current iteration
    
    % Get transformations and calculate local and global similarities
    [t_T, t_loc_c, t_glob_c, t_Tb, t_loc_cb, t_glob_cb, fwa, bwa] = get_transformations(img{1}, img{2});
    
    % Store forward and backward transformations and their similarities
    FWA{i} = fwa;   % Forward warping images for visualization
    BWA{i} = bwa;   % Backward warping images for visualization
    T{i} = t_T;     % Forward transformation matrix
    loc_c{i} = t_loc_c;  % Local similarity for forward transformation
    glob_c(i, 1) = t_glob_c;  % Global similarity for forward transformation
    Tb{i} = t_Tb;  % Backward transformation matrix
    loc_cb{i} = t_loc_cb;  % Local similarity for backward transformation
    glob_cb(i, 1) = t_glob_cb;  % Global similarity for backward transformation
end

% Concatenate forward and backward transformations and their similarities
T = [T, Tb];  % Combine forward and backward transformations
loc_c = [loc_c, loc_cb];  % Combine local similarities for forward and backward transformations
glob_c = [glob_c, glob_cb];  % Combine global similarities for forward and backward transformations

% Arrange and normalize the matrices and weights for alignment
[T, loc_c, glob_c] = arrange_matrix(T, loc_c, glob_c);

end

function [T, LocW, globW] = arrange_matrix(T_t, loc_c_t, glob_c_t)
% ARRANGE_MATRIX Organizes the transformation matrices, local weights, and global weights for alignment.
%   This function arranges transformation matrices and computes the local and global weights for alignment.
%
%   Input:
%       T_t     - Transformation matrices (forward and backward).
%       loc_c_t - Local similarity measures for each pair of projections.
%       glob_c_t - Global similarity measures for each pair of projections.
%
%   Output:
%       T       - The arranged transformation matrices for alignment.
%       LocW    - The local weights for each transformation pair.
%       globW   - The global weights for each transformation pair.

% Compute the session number from the size of the transformation matrices
n = round(max(roots([1 -1 -2 * size(T_t, 1)])));  % Session number (estimated)

% Initialize cell arrays for storing arranged transformation matrices and weights
T = cell(n);  % Transformation matrices
loc_w = cell(n);  % Local weights
glob_w = zeros(n, 1);  % Global weights

% Generate pairwise combinations of sessions for alignment
b = nchoosek(1:n, 2);
for i = 1:size(b, 1)
    % Arrange transformation matrices for forward and backward alignments
    T{b(i, 1), b(i, 2)} = T_t{i, 1};
    T{b(i, 2), b(i, 1)} = T_t{i, 2};
    
    % Arrange local similarity measures for forward and backward alignments
    loc_w{b(i, 1), b(i, 2)} = loc_c_t{i, 1};
    loc_w{b(i, 2), b(i, 1)} = loc_c_t{i, 2};
    
    % Set global similarity for forward and backward alignments
    glob_w(b(i, 1), b(i, 2)) = glob_c_t(i, 1);
    glob_w(b(i, 2), b(i, 1)) = glob_c_t(i, 2);
end

% Replace diagonal elements and standardize weights
for i = 1:n
    T{i, i} = T{1, 2} * 0;  % Set diagonal elements to zero (no self-alignment)
    LocW(:, :, i) = mean(cat(3, loc_w{i, :}), 3);  % Average the local weights for each session
    temp = glob_w(i, :);
    temp(i) = [];  % Remove the diagonal element
    globW(i) = mean(temp);  % Compute the average global weight
end

% Normalize the global weights so they sum to 1
globW = globW ./ sum(globW);

% Normalize the local weights by dividing by the sum along the third dimension
X = LocW ./ sum(LocW, 3);

% Apply Gaussian smoothing to the local weights to improve alignment
for i = 1:size(X, 3)
    X(:, :, i) = imgaussfilt(X(:, :, i), 8, 'FilterSize', 91);  % Apply Gaussian filter
end

% Normalize the smoothed local weights and store them
LocW = mat2gray(X) ./ sum(mat2gray(X), 3);

% If there are only two sessions, set the local weights to 0.5
if size(LocW, 3) == 2
    LocW = LocW * 0 + 0.5;  % Uniform weight if only two sessions
end

end

function [T, loc_c, glob_c, Tb, loc_cb, glob_cb, fwa, bwa] = get_transformations(M1, M2)
% GET_TRANSFORMATIONS Computes the forward and backward transformations between two images.
%   This function calculates both forward and backward transformations between the two images
%   (M1 and M2) using optical flow-based registration (Log-Demons method). It also computes 
%   the local and global similarities between the images.
%
%   Input:
%       M1 - The first image (projection).
%       M2 - The second image (projection).
%
%   Output:
%       T      - The forward transformation matrix.
%       loc_c  - The local similarity measure for the forward transformation.
%       glob_c - The global similarity measure for the forward transformation.
%       Tb     - The backward transformation matrix.
%       loc_cb - The local similarity measure for the backward transformation.
%       glob_cb - The global similarity measure for the backward transformation.
%       fwa    - The forward warping images (used for visualization).
%       bwa    - The backward warping images (used for visualization).

% Set up plotting parameters (turned off here)
plotme = 0;

% Define the optimization options for the Log-Demons registration method
opt{1, 1} = struct('stop_criterium', 0.001, 'imagepad', 1.5, 'niter', 100, 'sigma_fluid', 1, ...
    'sigma_diffusion', 3, 'sigma_i', 1, 'sigma_x', 1, 'do_display', plotme, 'do_plotenergy', plotme);
opt{2, 1} = struct('stop_criterium', 0.001, 'imagepad', 1.5, 'niter', 100, 'sigma_fluid', 1, ...
    'sigma_diffusion', 4, 'sigma_i', 1, 'sigma_x', 1, 'do_display', plotme, 'do_plotenergy', plotme);
opt{3, 1} = struct('stop_criterium', 0.001, 'imagepad', 1.5, 'niter', 100, 'sigma_fluid', 3, ...
    'sigma_diffusion', 3, 'sigma_i', 1, 'sigma_x', 1, 'do_display', plotme, 'do_plotenergy', plotme);
opt{4, 1} = struct('stop_criterium', 0.001, 'imagepad', 1.5, 'niter', 20, 'sigma_fluid', 3, ...
    'sigma_diffusion', 3, 'sigma_i', 1, 'sigma_x', 2, 'do_display', plotme, 'do_plotenergy', plotme);

% Extract the mean frame from M1 (used to calculate vignetting)
Mb = M1(:,:,1);  % The first frame (mean frame)
M1(:,:,1) = [];  % Remove the mean frame as it is not used in alignment
M2(:,:,1) = [];  % Remove the mean frame from M2 as well

%% Forward Registration
% Perform forward alignment (M1 to M2) using the Log-Demons method
[im1, im2, T, tS, im, e] = MR_Log_demon(M1, M2, opt);  % Forward alignment

% Create forward warping images for visualization
fwa = cat(4, im1(:,:,1:3), im2(:,:,1:3));  % Warp both images

% Compute the local similarity for the forward registration
loc_c = get_local_corr_Vf(cat(3, double(im1(:,:,2)), double(im2(:,:,2))), Mb);  % Local correlation based on BV

% Compute the global similarity for the forward registration using correlation
t1v = im1(:,:,2);  % Get the BV image for the forward registration
t2v = im2(:,:,2);  % Get the BV image for the backward registration
glob_c = 1 - pdist([double(t1v(:)'); double(t2v(:)')], 'correlation');  % Global similarity using correlation distance

T = squeeze(-T);  % Invert the transformation matrix (as Log-Demons returns inverse of the transformation)

%% Backward Registration
% Perform backward alignment (M2 to M1) using the Log-Demons method
[im1, im2, Tb] = MR_Log_demon(M2, M1, opt);  % Backward alignment

% Create backward warping images for visualization
bwa = cat(4, im1(:,:,1:3), im2(:,:,1:3));  % Warp both images

% Compute the local similarity for the backward registration
loc_cb = get_local_corr_Vf(cat(3, double(im1(:,:,2)), double(im2(:,:,2))), Mb);  % Local correlation based on BV

% Compute the global similarity for the backward registration using correlation
t1v = im1(:,:,end);  % Get the BV image for the forward registration
t2v = im2(:,:,end);  % Get the BV image for the backward registration
glob_cb = 1 - pdist([double(t1v(:)'); double(t2v(:)')], 'correlation');  % Global similarity using correlation distance

Tb = squeeze(-Tb);  % Invert the backward transformation matrix for consistency

end
