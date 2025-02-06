function img_filtered = remove_small_regions(img, min_pixels)
%REMOVE_SMALL_REGIONS Removes connected components with fewer than x pixels.
%   img_filtered = REMOVE_SMALL_REGIONS(img, min_pixels) takes a binary image 'img'
%   and removes any connected regions that have fewer than 'min_pixels' connected pixels.

% Find connected components
CC = bwconncomp(img);

% Remove small components
for i = 1:CC.NumObjects
    if numel(CC.PixelIdxList{i}) < min_pixels
        img(CC.PixelIdxList{i}) = 0;
    end
end

img_filtered = img;

end