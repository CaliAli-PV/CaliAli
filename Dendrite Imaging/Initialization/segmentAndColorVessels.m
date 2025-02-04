function [labeledImage,overlayedImage] = segmentAndColorVessels(Cn, minArea,thr, mask, plotme)
% [labeledImage,overlayedImage] = segmentAndColorVessels(Cn,50,0.1,[],1);
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
    mask = true(size(Cn)); % Default mask includes the whole image
end

% Apply the mask to the original image
Cn(~mask) = 0;

% Preprocessing
labeledImage=zeros(size(Cn));
filteredImage = medfilt2(Cn);
while 1
    % binaryImage = imbinarize(filteredImage,adaptthresh(filteredImage,thr...
    %     , 'NeighborhoodSize', [31 31]));
    binaryImage=filteredImage >thr;
    cleanedImage = bwareaopen(binaryImage, minArea);
    temp = bwlabel(cleanedImage);
    labeledImage(temp>0)=temp(temp>0)+max(labeledImage,[],'all');
    filteredImage(binaryImage)=0;
    if sum(cleanedImage,'all')==0
        break
    end
end

% --- Conditional Color and Overlay ---

    numVessels = max(labeledImage(:));
    coloredContours = zeros(size(Cn, 1), size(Cn, 2), 3);

    for k = 1:numVessels
        % Get the contour of the current vessel
        vesselMask = (labeledImage == k);
        vesselBoundary = bwboundaries(vesselMask); 

        % Assign a random color to this vessel's contour
        randomColor = [0.8 + (1.0 - 0.8) * rand(), 0.2 + (0.6 - 0.2) * rand(), 0.0 + (0.3 - 0.0) * rand()]; % Assign random redish color.
        
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

    overlayedImage = gray2rgb(Cn,'parula');
    overlayedImage(coloredContours > 0) = coloredContours(coloredContours > 0);
if plotme
    imshow(overlayedImage); 
end
end