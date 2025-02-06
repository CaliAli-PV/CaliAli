function overlayed_image = overlay_regions(img, label_matrix)
%OVERLAY_REGIONS Overlays labeled regions on an image using different colors.
%   overlayed_image = OVERLAY_REGIONS(img, label_matrix) takes an image 'img' 
%   and a label matrix 'label_matrix' as input. It overlays the regions 
%   defined in the label matrix onto the image using different colors for 
%   each region.

% Convert the label matrix to an RGB image with a distinct color for each label
colored_labels = label2rgb(label_matrix, 'jet', 'k', 'shuffle'); 

% Blend the colored labels with the original image (adjust alpha as needed)
alpha = 0.5; % Transparency level (0 = fully transparent, 1 = fully opaque)
overlayed_image = imfuse(img, colored_labels, 'blend', 'Scaling', 'joint')
end