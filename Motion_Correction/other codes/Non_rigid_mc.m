function V = Non_rigid_mc(V, ref, opt)
% Non_rigid_mc performs non-rigid motion correction on a video.
%
%   V = Non_rigid_mc(V, ref, opt)
%
%   This function performs non-rigid motion correction on an input video 
%   using a multi-level registration approach. It utilizes a pyramid of 
%   images (e.g., blood vessel and neuron projections) and applies 
%   log-domain demons registration to align the frames.
%
%   Inputs:
%       V   - Input video as a 3D array (height x width x frames).
%       ref - Reference image for initial alignment.
%       opt - Structure containing registration options.
%
%   Outputs:
%       V   - Motion-corrected video.


% Get a pyramid of images (e.g., blood vessel and neuron projections)
fprintf('Appling non-rigid motion correction...\n');
[X] = get_video_pyramid(V, ref, opt); 

% Perform non-rigid motion correction in parallel
V = NR_motion_correction_parallel(X, V, opt);  
end


function V = NR_motion_correction_parallel(X, V, opt)
% NR_motion_correction_parallel performs parallel non-rigid motion correction.
%
%   V = NR_motion_correction_parallel(X, V, opt)
%
%   This function performs non-rigid motion correction on a video in parallel 
%   by dividing it into smaller batches and registering each batch independently.
%
%   Inputs:
%       X   - 4D array of images (pyramid) used for registration.
%       V   - Input video as a 3D array.
%       opt - Structure containing registration options.
%
%   Outputs:
%       V   - Motion-corrected video.

% Calculate translation scores on the last level of the pyramid (neurons by default)
[ms1, ~] = get_trans_score(mat2gray(squeeze(X(:,:,1,:))), [], 1, 1, 0.3); 

% Distribute the video into smaller batches for parallel processing
[MS, G, V] = distribute(X, V, ms1, opt.non_rigid_batch_size);  

% Perform motion correction on each batch in parallel
[V, G] = MC_in(MS, G, V, opt.non_rigid_options);  

% Concatenate the processed batches to reconstruct the video
V = cat(3, V{:});  
X = cat(4, G{:});
end


function [MS, G, Vc] = distribute(X, V, ms, win)
% distribute divides a video into smaller batches for parallel processing.
%
%   [MS, G, Vc] = distribute(X, V, ms, win)
%
%   This function divides a video into smaller batches based on motion scores 
%   and a specified window size.
%
%   Inputs:
%       X   - 4D array of images (pyramid) used for registration.
%       V   - Input video as a 3D array.
%       ms  - Motion scores used to determine batch boundaries.
%       win - 2-element vector specifying the minimum and maximum batch size.
%
%   Outputs:
%       MS  - Cell array of motion scores for each batch.
%       G   - Cell array of image pyramids for each batch.
%       Vc  - Cell array of video batches.

disp('Distributing video in small batches...');

% Identify regions of low motion to define batch boundaries
v = movmedian(ms < prctile(ms, 50), 50) > 0.5;  
v(1:win(2):end) = 0;  % Ensure minimum spacing between batches
CC = bwlabel(v);  % Label connected components

% Remove small regions to ensure minimum batch size
rp = regionprops(logical(CC), 'area');
for i = 1:max(CC)
    if rp(i).Area < win(1)
        CC(CC == i) = 0;
        CC(CC > i) = CC(CC > i) - 1;
    end
end

% Fill gaps between batches using nearest neighbor interpolation
CC(CC == 0) = nan;
CC = fillmissing(CC, 'nearest');

% Distribute the video and image pyramids into batches
for i = 1:max(CC)
    MS{i} = ms(CC == i);
    G{i} = X(:,:,:,CC == i);
    Vc{i} = V(:,:,CC == i);
end
end


function [V, G] = MC_in(MS, G, V, opt)
% MC_in performs motion correction within each batch.
%
%   [V, G] = MC_in(MS, G, V, opt)
%
%   This function performs motion correction within each batch of a video 
%   using the provided registration options.
%
%   Inputs:
%       MS  - Cell array of motion scores for each batch.
%       G   - Cell array of image pyramids for each batch.
%       V   - Cell array of video batches.
%       opt - Structure containing registration options.
%
%   Outputs:
%       V   - Cell array of motion-corrected video batches.
%       G   - Cell array of registered image pyramids.

% Perform motion correction within each batch in parallel
disp('Performing non-rigid motion correction...');
parfor k = 1:length(MS)
    [~, ix] = min(MS{k});  % Find the frame with the lowest motion score
    T = G{k}(:,:,:,ix);  % Use this frame as the reference for registration
    [G{k}, ~, V{k}] = batch_register(G{k}, V{k}, opt, T);  % Register the batch
end
end


function [O, D, V] = batch_register(G, V, opt, T)
% batch_register registers a batch of images to a reference image.
%
%   [O, D, V] = batch_register(G, V, opt, T)
%
%   This function registers a batch of images to a reference image using 
%   log-domain demons registration.
%
%   Inputs:
%       G   - 4D array of images to register.
%       V   - 3D array of video frames corresponding to the images.
%       opt - Structure containing registration options.
%       T   - Reference image for registration.
%
%   Outputs:
%       O   - 4D array of registered images.
%       D   - 4D array of displacement fields.
%       V   - 3D array of registered video frames.

O(:,:,:,1) = T;  % Initialize the first registered image as the reference
D = zeros(size(T,1), size(T,2), 2, size(G,4));  % Initialize displacement fields

% Register each image to the reference
for i = 1:size(G,4)
    [~, O(:,:,:,i), D(:,:,:,i)] = MR_Log_demon(T, G(:,:,:,i), opt); 
end

% Warp the video frames based on the calculated displacement fields
for i = 1:size(G,4)
    V(:,:,i) = imwarp(V(:,:,i), D(:,:,:,i), 'FillValues', 0);
end
end


function X = get_video_pyramid(Y, ref, opt)
% get_video_pyramid creates a pyramid of images for registration.
%
%   X = get_video_pyramid(Y, ref, opt)
%
%   This function creates a pyramid of images (e.g., blood vessel and neuron 
%   projections) based on the specified order in the options.
%
%   Inputs:
%       Y   - Input video as a 3D array.
%       ref - Reference image utilized during translations. This is to
%       avoid recalculating this projections. 
%       opt - Structure containing registration options.
%
%   Outputs:
%       X   - 4D array of images (pyramid).

order = opt.non_rigid_pyramid;  % Get the desired order of projections

% If the reference projection used during translation is 'BV'
if strcmp(opt.reference_projection_rigid, 'BV')  
    BV = ref;  % Assign the reference image to BV
    if ismember('neuron', order)  % If 'neuron' is in the order
        Neu = CaliAli_remove_background(Y, opt);  % Calculate neuron projection
    else
        Neu = [];  % Otherwise, set Neu to empty
    end
    clear ref;  % Delete the original reference image

% If the reference projection used during translation is 'neuron'
elseif strcmp(opt.reference_projection_rigid, 'neuron')  
    Neu = ref;  % Assign the reference image to Neu
    if ismember('BV', order)  % If 'BV' is in the order
        BV = CaliAli_get_blood_vessels(Y, opt);  % Calculate blood vessel projection
    else
        BV = [];  % Otherwise, set BV to empty
    end
    clear ref;    % Delete the original reference image
end

X = [];  % Initialize the image pyramid
order=flip(order);
% Construct the pyramid based on the specified order
for i = 1:numel(order)  
    switch order{i}
        case 'BV'
            X = cat(4, X, v2uint8(BV));  % Concatenate BV along the 4th dimension
        case 'neuron'
            X = cat(4, X, v2uint8(Neu));  % Concatenate Neu along the 4th dimension
    end
end

% Permute the dimensions for proper registration
X = permute(X, [1, 2, 4, 3]);  
end