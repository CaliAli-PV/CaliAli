function [Y_box, ind_nhood, comp_mask, sz,Cn_out] = get_mini_videos_dendrite(Y, segments, neuron,Cn,seed)
%GET_MINI_VIDEOS_DENDRITE Extracts mini-videos around seed points on a dendrite.
%
%   [Y_box, ind_nhood, center, sz] = get_mini_videos_dendrite(Y, seed, neuron)
%
%   Inputs:
%       Y           - Matrix of fluorescence traces (pixels x time).
%       seed        - Linear indices of seed points on the dendrite.
%       neuron      - Structure containing neuron parameters, including:
%                       - options.d1: Image height (number of rows).
%                       - options.d2: Image width (number of columns).
%                       - options.gSig: Gaussian sigma for neighborhood size.
%        Cn         - Optional: Correlation image. 
%
%   Outputs:
%       Y_box       - Cell array of mini-videos (pixel values x time) around each seed.
%       ind_nhood  - Cell array of linear indices of pixels in each neighborhood.
%       center      - Cell array of linear indices of the center pixel in each neighborhood.
%       sz          - Cell array of sizes (rows x columns) of each neighborhood.

% Get image dimensions and Gaussian sigma from neuron structure
d1 = neuron.options.d1;
d2 = neuron.options.d2;
gSig = neuron.options.gSig;

% Calculate neighborhood size based on Gaussian sigma
if numel(gSig) < 2
    gSiz = [gSig * 6, gSig * 6];  % Use 6*sigma if only one sigma value is provided
else
    gSiz = gSig .* 4 * 2.5;       % Use 4*sigma*1.5 if two sigma values are provided 
end

% Initialize output cell arrays
Y_box = {};
ind_nhood = {};
comp_mask = {};
sz = {};

if ~exist('Cn','var')
    Cn=zeros(d1,d2);
end

% Loop through each seed point
for k = 1:numel(seed)
    [squareMask,comp_mask{k}] = getBoundingSquareMask(segments==seed(k), gSiz);
    sz{k}=[max(sum(squareMask,1)),max(sum(squareMask,2))];
    Cn_out{k}=reshape(Cn(squareMask),max(sum(squareMask,1)),max(sum(squareMask,2)));

    % Calculate linear indices of pixels in the neighborhood
    ind_nhood{k} = find(squareMask);

    % Extract pixel values (fluorescence traces) within the neighborhood
    Y_box{k} = single(Y(squareMask(:), :)); 
end

end


function [squareMask,comp_mask] = getBoundingSquareMask(binaryImage, minBoxSize)
%getBoundingSquareMask Creates a binary mask with a square that surrounds 
%                      a blob in a binary image, with a minimum box size.
%
%   squareMask = getBoundingSquareMask(binaryImage, minBoxSize)
%
%   Inputs:
%       binaryImage: The input binary image containing a single blob.
%       minBoxSize:  A 2-element vector specifying the minimum width and 
%                    height of the bounding box [minWidth, minHeight].
%
%   Output:
%       squareMask:  A binary mask with a square that encloses the blob 
%                    and satisfies the minimum box size constraint.


% Find the bounding box of the blob
[rows, cols] = find(binaryImage);
minRow = min(rows);
maxRow = max(rows);
minCol = min(cols);
maxCol = max(cols);

% Calculate the bounding box dimensions
width = maxCol - minCol + 1;
height = maxRow - minRow + 1;

% Adjust dimensions to meet the minimum size
width = max(width, minBoxSize(1));
height = max(height, minBoxSize(2));

% Calculate the center of the bounding box
centerRow = round((minRow + maxRow) / 2);
centerCol = round((minCol + maxCol) / 2);

% Calculate the coordinates of the square with adjusted dimensions
halfWidth = floor(width / 2);
halfHeight = floor(height / 2);
rowStart = max(1, centerRow - halfHeight); % Handle borders
rowEnd = min(size(binaryImage, 1), centerRow + halfHeight);
colStart = max(1, centerCol - halfWidth);
colEnd = min(size(binaryImage, 2), centerCol + halfWidth);

% Create the square mask
squareMask = false(size(binaryImage));
squareMask(rowStart:rowEnd, colStart:colEnd) = true;
comp_mask=binaryImage(rowStart:rowEnd, colStart:colEnd);


end
