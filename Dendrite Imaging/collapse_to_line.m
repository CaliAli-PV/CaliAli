function [centroid, angle] = collapse_to_line(region, plot_line)
%GET_LINE_EQUATION Calculates the centroid and orientation of a region, with optional plot.
%   [centroid, angle] = GET_LINE_EQUATION(region, plot_line) takes a binary image 
%   'region' containing a single connected component and a boolean flag 'plot_line'. 
%   It returns the centroid coordinates and the orientation of the region in degrees. 
%   If 'plot_line' is true, it also plots a line representing the region's orientation 
%   on top of the region image.

% Find coordinates of the region's pixels
[rows, cols] = find(region);
points = [cols, rows];

% Perform PCA to find the principal axis
coeff = pca(points);
principal_axis = coeff(:, 1); 

% Calculate the centroid of the region
centroid = mean(points);

% Calculate the angle in degrees
angle = atan2(principal_axis(2), principal_axis(1)) * 180 / pi; 

% Plot the line if requested
if plot_line
    imshow(region);
    hold on;
    
    % Calculate the end points of the line for plotting
    line_length = max(size(region)); % Adjust line length as needed
    x_coords = centroid(1) + line_length * [-1, 1] * principal_axis(1);
    y_coords = centroid(2) + line_length * [-1, 1] * principal_axis(2);
    
    h=plot(x_coords, y_coords, 'r--', 'LineWidth', 2);  % Plot the line in red
    h.Color(4) = 0.3;
    scatter(centroid(1),centroid(2),'og')
    hold off;
end