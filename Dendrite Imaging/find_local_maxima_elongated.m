function combined_maxima = find_local_maxima_elongated(in, angles, psf_len)
    % Function to find local maxima of elongated objects in multiple orientations
    % Inputs:
    %   in      - input image (grayscale or color)
    %   angles  - vector of angles (in degrees) to test for elongated structures
    %   psf_len - length of the structuring element (line filter)
    %
    % Output:
    %   combined_maxima - image highlighting the local maxima across all orientations
  
    
    % Initialize stack for results
    maxima_stack = zeros([size(in), numel(angles)]);
    
    % Loop through each angle and apply the filter
    for i = 1:numel(angles)              % Structuring element
        psf=rotated_rectangle(angles(i), psf_len(2), psf_len(1));
        maxima_stack(:, :, i) = ordfilt2(in, sum(psf,'all'),psf);
    end
    
    % Combine results by taking the maximum across orientations
    combined_maxima = max(maxima_stack, [], 3);
end


function se_rotated = rotated_rectangle(x, height, width)
    % Create a binary image with a rectangle
    rect = zeros(2*max(height, width));  % Create a large enough empty matrix
    center = size(rect) / 2;  % Center of the matrix
    rect(floor(center(1)-width/2):floor(center(1)+width/2), ...
         floor(center(2)-height/2):floor(center(2)+height/2)) = 1;  % Draw the rectangle

    % Rotate the rectangle by x degrees
     se_rotated = imrotate(rect, x, "nearest",'crop');  % Crop keeps the same size as input

    % Convert the rotated binary image to a logical structuring element
end
