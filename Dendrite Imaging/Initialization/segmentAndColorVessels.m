function [labeledImage,overlayedImage] = segmentAndColorVessels(originalImage, minArea,thr, mask, plotme)
%segmentAndColorVessels  Segments vessels in an image within a specified
%                        mask and labels them with different colors.
%                        Optionally displays the result.
%
%   labeledImage = segmentAndColorVessels(originalImage, minArea, mask, plotme)
%
%   Inputs:
%       originalImage: The input grayscale image containing vessels.
%       minArea:      The minimum area (in pixels) of connected components
%                     to keep after thresholding.
%       mask:         (Optional) A binary mask image of the same size as
%                     originalImage. Only the regions where the mask is true
%                     (or non-zero) will be considered for segmentation.
%                     If an empty array ([]) is provided, the entire image
%                     will be processed.
%       plotme:       (Optional) A boolean flag indicating whether to
%                     display the segmented and colored vessels.
%                     Defaults to false if not provided.
%
%   Output:
%       labeledImage: A labeled image where each connected vessel region
%                     is assigned a different integer label.


% Set default values for optional inputs
if ~exist('plotme','var')
    plotme = false;
end
if ~exist('mask','var')
    mask = true(size(originalImage)); % Default mask includes the whole image
end

% Apply the mask to the original image
originalImage(~mask) = 0;

% Apply the mask to the original image
originalImage(~mask) = 0;

% Preprocessing
enhancedImage = imadjust(originalImage);
filteredImage = medfilt2(enhancedImage);

% Thresholding
binaryImage = imbinarize(filteredImage, adaptthresh(filteredImage,thr ...
    , 'NeighborhoodSize', [51 51]));

% Morphological Operations to remove small objects (using minArea)
cleanedImage = bwareaopen(binaryImage, minArea);

% Label connected components (each vessel gets a unique label)
labeledImage = bwlabel(cleanedImage);

% --- Conditional Color and Overlay ---

    numVessels = max(labeledImage(:));
    coloredContours = zeros(size(originalImage, 1), size(originalImage, 2), 3);

    for k = 1:numVessels
        % Get the contour of the current vessel
        vesselMask = (labeledImage == k);
        vesselBoundary = bwboundaries(vesselMask); 

        % Assign a random color to this vessel's contour
        randomColor = rand(1, 3);
        
        % Overlay the contour on the coloredContours image
        for j = 1:length(vesselBoundary)
            boundary = vesselBoundary{j};
            for n = 1:length(boundary)
                row = boundary(n,1);
                col = boundary(n,2);
                coloredContours(row, col, :) = randomColor; 
            end
        end
    end

    overlayedImage = gray2rgb(originalImage);
    overlayedImage(coloredContours > 0) = coloredContours(coloredContours > 0);
if plotme
    imshow(overlayedImage); 
end
end