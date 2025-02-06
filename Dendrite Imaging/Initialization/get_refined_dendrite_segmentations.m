function [labeled_all,overlayedImage] = get_refined_dendrite_segmentations(Cn, minArea, thr,mask,plotme)
% Segments dendrites using adaptive thresholding, morphology, and active contours.
%
%   Args:
%       Cn      - Input image.
%       minArea - Minimum area of a dendrite segment.
%       thr     - Threshold for segmentation and SNR filtering.
%       plotme  - Flag to display the final image.
%       mask:         (Optional) A binary mask image of the same size as
%                     originalImage. Only the regions where the mask is true
%                     (or non-zero) will be considered for segmentation.
%                     If an empty array ([]) is provided, the entire image
%                     will be processed.
%
%   Output:
%       labeled_all - Labeled image of segmented dendrites.
%       overlayedImage - RGB image with segment boundaries overlaid on the input image.

% Set default values for optional inputs
if ~exist('plotme','var')
    plotme = false;
end
if ~exist('mask','var')
    mask = true(size(Cn)); % Default mask includes the whole image
end

% Apply the mask to the original image
Cn(~mask) = 0;

filteredImage = medfilt2(Cn); % Noise reduction with median filter.
k=0;
out=filteredImage*0;
filteredImage=double(filteredImage);

% --- Main Segmentation Loop ---
x=linspace(0.5,thr,5);
for i=progress(1:length(x))
    binaryImage=filteredImage >x(i); % Binarization.
    while 1
        cleanedImage = bwareaopen(binaryImage, minArea); % Remove small objects.
        labeledImage = bwlabel(cleanedImage); % Label connected components.
        if max(labeledImage,[],'all')>0
            k=k+1;
        else
            break
        end
        stats = regionprops(cleanedImage, 'Area');
        [~,I]=max([stats.Area]);
        labeledImage =labeledImage ==I; % Keep largest blob.
        expanded = activecontour(filteredImage,labeledImage,'Chan-Vese','ContractionBias',-0.3); % Refine with active contours.
        mainBranch = isolateLargestBranch(expanded); % Isolate largest branch.
        out(mainBranch)=k;
        mainBranch=imdilate(mainBranch,ones(2));
        binaryImage(mainBranch)=0;
        filteredImage(mainBranch)=0;
    end
end

% --- Postprocessing: Filter by Area and SNR ---
for i=1:max(out,[],'all')
    area=sum(out==i,'all');
    snr=mean(Cn(out==i));
    if area<minArea||snr<thr
      out(out==i)=0;
    end
end

% --- Relabel Segments ---
uniqueLabels = unique(out(:));
mapping = containers.Map(uniqueLabels, 0:length(uniqueLabels)-1);
labeled_all = arrayfun(@(x) mapping(x), out);

% --- Visualization ---
    numVessels = max(labeled_all(:));
    coloredContours = zeros(size(Cn, 1), size(Cn, 2), 3);
    for k = 1:numVessels
        vesselMask = (labeled_all == k);
        vesselBoundary = bwboundaries(vesselMask);
        randomColor = [0.8 + (1.0 - 0.8) * rand(), 0.2 + (0.6 - 0.2) * rand(), 0.0 + (0.3 - 0.0) * rand()]; % Assign random redish color.
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
