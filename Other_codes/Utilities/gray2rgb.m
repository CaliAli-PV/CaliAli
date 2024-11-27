function rgbVideo=gray2rgb(grayVideo,colormapName)

% grayToColormap converts a grayscale video to RGB using the specified colormap.
%
% Inputs:
%   grayVideo   - Grayscale video array of size d1xd2xN (where N is the number of frames)
%   colormapName - A string specifying the colormap to use (e.g., 'hot', 'jet', etc.)
%
% Output:
%   rgbVideo    - RGB video array of size d1xd2x3xN

if ~exist('colormapName','var')
    colormapName= 'gray';
end
grayVideo=v2uint8(grayVideo);


% Get the size of the input grayscale video
[d1, d2, numFrames] = size(grayVideo);

% Get the colormap function based on the provided colormap name
if ischar(colormapName)
cmap = feval(colormapName, 256);  % Create a 256-level colormap
else
    cmap=linspace(0,1,256)'*colormapName;
end

% Preallocate the RGB video array
rgbVideo = zeros(d1, d2, 3, numFrames);

% Loop through each frame and convert using the specified colormap
for i = 1:numFrames
    % Convert the indexed image to RGB using the chosen colormap
    rgbVideo(:,:,:,i) = ind2rgb(grayVideo(:,:,i), cmap);
end
end
