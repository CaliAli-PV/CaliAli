function M=CaliAli_get_blood_vessels(M,opt)
%% CaliAli_get_blood_vessels: Enhance blood vessels in an image or video.
%
% This function enhances the visibility of blood vessels in an input image 
% or video using a combination of vignetting removal, vesselness filtering, 
% and median filtering.
%
% Inputs:
%   M   - Input image or video as a 2D or 3D array (grayscale or color).
%   opt - (Optional) Structure containing processing parameters:
%         opt.BVsize - 2-element vector specifying the range of vessel 
%                      scales (in pixels) for the vesselness filter 
%                      (default: [1.5, 2.25]).
%
% Outputs:
%   M   - Processed image or video with enhanced blood vessels.
%
% Usage:
%   M = CaliAli_get_blood_vessels(M, opt);
%
% Notes:
%   - For videos (3D arrays), parallel processing is used for efficiency.
%   - Vignetting removal is performed using morphological opening and 
%     anisotropic diffusion filtering.
%   - Vesselness filtering is applied to enhance blood vessel structures.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Set default parameters if 'opt' is not provided
if ~exist('opt','var')
    opt.BVsize=[0.6*2.5,0.9*2.5];  % Default vessel scale range
end

% Check if the input is a single image or a video
if size(M,3)>1
    parf=1;  % Use parallel processing for videos
else
    parf=0;  % Process single images sequentially
end

% Convert the input to single precision for processing
M=single(M);  

% Calculate the size of the structuring element for vignetting removal
sz=round(max(size(M,[1,2]))/8);  
se = offsetstrel('ball',sz,0.01);  % Create a ball-shaped structuring element

% Estimate vignetting removal parameters from the first frame (for videos)
[~,gradThresh,numIter]=remove_vignetting(M(:,:,1),se); 

% Process the input
if parf==1  % Parallel processing for videos
    M = create_batches(M);  % Divide the video into batches
    bv_scale = linspace(opt.BVsize(1), opt.BVsize(2), 10);  % Vessel scales for vesselness filter
    fprintf('Calculating blood vessels in batch mode...\n');
    parfor i = 1:size(M,1)
        M{i} = process_batch(M{i}, se, gradThresh, numIter, bv_scale); % Process each batch in parallel
    end
    M = cat(3,M{:});  % Concatenate the processed batches
else  % Sequential processing for single images
    fprintf('Calculating blood vessels...\n');
    [M,~,~] = remove_vignetting(M,se,gradThresh,numIter);  % Remove vignetting
    M = M + randn(size(M))/10000;  % Add small noise to avoid artifacts
    M = mat2gray(vesselness_PV(M,0,linspace(opt.BVsize(1),opt.BVsize(2),10),2)); % Apply vesselness filter
    M = medfilt2(M,'symmetric');  % Apply median filtering
end
end

function [M,gradThresh,numIter]=remove_vignetting(M,se,gradThresh,numIter)
% remove_vignetting removes vignetting from an image.
%
%   [M, gradThresh, numIter] = remove_vignetting(M, se, gradThresh, numIter)
%
%   This function removes vignetting (darkening towards the edges) 
%   from an image using morphological opening and anisotropic diffusion 
%   filtering.
%
%   Inputs:
%       M           - Input image.
%       se          - Structuring element for morphological opening.
%       gradThresh  - (Optional) Gradient threshold for anisotropic diffusion.
%       numIter     - (Optional) Number of iterations for anisotropic diffusion.
%
%   Outputs:
%       M           - Vignetting-corrected image.
%       gradThresh  - Estimated gradient threshold.
%       numIter     - Estimated number of iterations.

R = M - imopen(M,se);  % Subtract the morphologically opened image to highlight vignetting

% Estimate diffusion parameters if not provided
if ~exist('gradThresh','var')
    [gradThresh,numIter] = imdiffuseest(R,'ConductionMethod','quadratic'); 
end

% Apply anisotropic diffusion filtering to remove vignetting
M = mat2gray(imdiffusefilt(R, 'ConductionMethod','quadratic', ...
    'GradientThreshold',gradThresh,'NumberOfIterations',numIter));
end

function M=create_batches(M)
% create_batches divides a 3D array into batches along the third dimension.
%
%   M = create_batches(M)
%
%   This function divides a 3D array into smaller 3D batches along the 
%   third dimension (useful for dividing a video into chunks).
%
%   Inputs:
%       M  - Input 3D array.
%
%   Outputs:
%       M  - Cell array where each cell contains a 3D batch.

[d1, d2, f] = size(M);   % Get the dimensions of the original array
batch_size = 100;        % Define the batch size

% Calculate the size of each batch along the third dimension
batch_sizes = [repmat(batch_size, 1, floor(f / batch_size)), mod(f, batch_size)];

% Remove the last entry if it is 0, since mod(f, batch_size) could be 0
if batch_sizes(end) == 0
    batch_sizes(end) = [];
end

% Divide the array into batches using mat2cell
M = squeeze(mat2cell(M, d1, d2, batch_sizes)); 
end

function in=process_batch(in,se,gradThresh,numIter,bv_scale)
% process_batch processes a batch of images to enhance blood vessels.
%
%   in = process_batch(in, se, gradThresh, numIter, bv_scale)
%
%   This function processes a batch of images (a 3D array) to enhance 
%   blood vessels. It applies vignetting removal, vesselness filtering, 
%   and median filtering to each image in the batch.
%
%   Inputs:
%       in          - Input 3D array (batch of images).
%       se          - Structuring element for vignetting removal.
%       gradThresh  - Gradient threshold for anisotropic diffusion.
%       numIter     - Number of iterations for anisotropic diffusion.
%       bv_scale    - Vessel scales for vesselness filtering.
%
%   Outputs:
%       in          - Processed 3D array with enhanced blood vessels.

    [d1, d2, num_frames] = size(in);
    noise = randn(d1, d2, 'single') / 10000; % Precompute noise array
    for i = 1:num_frames
        frame = in(:,:,i);
        frame = remove_vignetting(frame, se, gradThresh, numIter);
        frame = frame + noise;  % Add precomputed noise
        frame = mat2gray(vesselness_PV(frame, 0, bv_scale, 0));
        in(:,:,i) = medfilt2(frame, 'symmetric');  % Update the frame directly
    end
end