function [seedPixels,skel,seed_linear_ix] = findCentralSeedsGray(grayImage, thr, minBranchLength,mask)
% Finds seed pixels in the center of branches in a grayscale image,
% returns segments, and displays results in two panels.
%
% Args:
%   grayImage: The grayscale image containing the elongated structures.
%   thr: The threshold value for binarization (0 to 255).
%   minBranchLength: The minimum length (in pixels) of a branch to be
%                   considered for seed placement. Shorter branches are ignored.
%
% Returns:
%   segments: A structure array containing information about each detected
%             segment (dendrite branch). Each element of the array has
%             the following fields:
%               - PixelList: The list of pixels belonging to the segment.
%               - SeedPixel: The coordinates of the seed pixel for the segment.

    % 1. Binarization
   grayImage  = imadjust(grayImage );
    filteredImage = medfilt2(grayImage );
    d=round(max(size(grayImage))/10);
% Thresholding
    binaryImage = imbinarize(filteredImage , adaptthresh(filteredImage , thr,'NeighborhoodSize', [d d])); 

    % 2. Skeletonization with Pruning
    skeleton = bwskel(binaryImage);
    for i = 1:minBranchLength 
        skeleton = bwmorph(skeleton, 'spur');
    end
    
    skeleton=skeleton.*mask;
    % 3. Find branch points and endpoints
    branchPoints = bwmorph(skeleton, 'branchpoints');

    % 4. Remove branch points temporarily to segment the skeleton
    noBranchPoints = skeleton & ~branchPoints;

    % 5. Find connected components (segments/branches)
    CC = bwconncomp(noBranchPoints);

    % 6. Get segment properties
    segmentData = regionprops(CC, 'PixelList');

    % 7. Iterate through segments and find central seeds
    seedPixels = [];
    segments = struct('PixelList', {}, 'SeedPixel', {}); % Initialize segments
    validSegmentIndex = 1; % Index for valid segments

    for i = 1:length(segmentData)
        segment = segmentData(i).PixelList;
        segmentLength = size(segment, 1);

        % Check if the segment is long enough
        if segmentLength >= minBranchLength
            % Calculate the midpoint (approximately the center)
            midIndex = round(segmentLength / 2);
            midPoint = segment(midIndex, :); % (col, row) format

            % Add seed pixel (convert to row, column format)
            seedPixel = [midPoint(2), midPoint(1)];
            seedPixels = [seedPixels; seedPixel];

            % Store segment information for valid segments
            segments(validSegmentIndex).PixelList = segment;
            segments(validSegmentIndex).SeedPixel = seedPixel;
            validSegmentIndex = validSegmentIndex + 1;
        end
    end

    % 8. Visualization
    % Create a labeled image for visualization
    labeledImage = labelmatrix(CC);

    % Create an RGB image for displaying segments in different colors
    RGB_label = label2rgb(labeledImage, 'jet', 'k', 'shuffle');

    % Binary image with colored segments and seed pixels
    skel=gray2rgb(grayImage);
    skel(RGB_label>0)=RGB_label(RGB_label>0);
    seed_linear_ix=sub2ind(size(grayImage),seedPixels(:,1),seedPixels(:,2));
end