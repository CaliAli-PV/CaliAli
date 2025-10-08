function V = Non_rigid_mc(V, ref, opt)
%% Non_rigid_mc: Perform non-rigid motion correction using multi-level registration.
%
% This function applies non-rigid motion correction to an input video using a
% multi-level registration approach. It constructs a pyramid of images (e.g.,
% blood vessel and neuron projections) and applies log-domain demons registration
% to align frames while preserving fine details.
%% Note: This code is experimental and may introduce undesired deformations when adjusting for non-rigid deformation.
%
% Inputs:
%   V   - Input video as a 3D array (height x width x frames).
%   ref - Reference image for initial alignment.
%   opt - Structure containing registration options.
%
% Outputs:
%   V   - Motion-corrected video.
%
% Usage:
%   V_corrected = Non_rigid_mc(V, ref, opt);
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Get a pyramid of images (e.g., blood vessel and neuron projections)

fprintf('Appling non-rigid motion correction...\n');

cprintf('*red',['Non-rigid motion correction is not currenlty supported!. ', ...
         'Usage is experimental.\n']);
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
V = MC_in(MS, G, V, opt.non_rigid_options);


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


function V = MC_in(MS, G, V, opt)
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
    D{k} = batch_register(G{k},opt, MS{k});  % Register the batch
end

% Warp the video frames based on the calculated displacement fields

D=cat(4,D{:});

D(:,:,1,:) = imgaussfilt3(squeeze(D(:,:,1,:)),[0.5,0.5,2]);
D(:,:,2,:) = imgaussfilt3(squeeze(D(:,:,2,:)),[0.5,0.5,2]);

V=cat(3,V{:});

for i = progress(1:size(D,4),'Title','Applying shifts')
    V(:,:,i) = imwarp(V(:,:,i), D(:,:,:,i), 'FillValues', 0);
end

end


function [D] = batch_register(G,opt, MS)
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
%       MS   - Motions scores.
%
%   Outputs:
%       O   - 4D array of registered images.
%       D   - 4D array of displacement fields.
%       V   - 3D array of registered video frames.

[~, ix] = min(MS);  % Find the frame with the lowest motion score

ref=G(:,:,:,ix);
[d1,d2,~,d4]=size(G);
D=zeros(d1,d2,2,d4);
thr=prctile(G(G>0),5);
[~,order]=sort(abs((1:d4)-ix),'ascend');

for i = 1:numel(order)
    [~, temp(:,:,:,i), D(:,:,:,order(i))] = MR_Log_demon(ref,G(:,:,:,order(i)), opt);
    temp(temp<thr)=nan;
    ref=mean(temp,4,'omitnan');
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
    if ismember('neuron', order)|| ismember('centroid', order)  % If 'neuron' is in the order
        Neu = CaliAli_remove_background(Y, opt);  % Calculate neuron projection
        se=strel("disk",2);
        Neu=v2uint8(Neu);
        Neu(Neu>100)=100;
        Neu=v2uint8(Neu);
        Neu(Neu<30)=0;
        parfor i=1:size(Neu,3)
            temp=Neu(:,:,i);
            temp=imopen(temp,se);
            Neu(:,:,i)=adapthisteq(temp,"distribution","exponential");
        end

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

if  ismember('centroid', order)
    Neu=v2uint8(Neu);
    thr=prctile(Neu(Neu>0),5);
    for i=progress(1:size(Neu,3),'Title','Getting centroids')
        img=Neu(:,:,i)>thr;
        stats = regionprops(img, 'Centroid'); % Get centroids of blobs

        % Create an empty image and mark centroids
        dot_img = false(size(img));

        for k = 1:length(stats)
            centroid = round(stats(k).Centroid); % Get integer centroid
            dot_img(centroid(2), centroid(1)) = 1; % Mark as a dot
        end
        centroid_img(:,:,i) = adapthisteq(imgaussfilt(single(dot_img),2),'NumTiles',[4 4],'ClipLimit',0.8);
    end
end

X = [];  % Initialize the image pyramid
order=flip(order);
% Construct the pyramid based on the specified order
for i = 1:numel(order)
    switch order{i}
        case 'BV'
            X = cat(4, X, v2uint8(BV));  % Concatenate BV along the 4th dimension
        case 'neuron'
            X = cat(4, X,Neu);  % Concatenate Neu along the 4th dimension
        case 'centroid'
            X = cat(4,X,v2uint8(centroid_img));
    end
end

% Permute the dimensions for proper registration
X = permute(X, [1, 2, 4, 3]);
end