function parallel_matrix = find_parallel_lines(centroids, angles, angle_threshold, distance_threshold)
%FIND_PARALLEL_LINES Finds pairs of approximately parallel lines within a distance threshold.
%   parallel_matrix = FIND_PARALLEL_LINES(centroids, angles, angle_threshold, distance_threshold)
%   takes a list of centroids (Nx2 matrix), their corresponding angles (Nx1 vector),
%   an angle threshold 'angle_threshold', and a distance threshold 'distance_threshold' 
%   as input. It returns a binary square matrix 'parallel_matrix' where an element (i, j) is 1 
%   if lines i and j are approximately parallel (angle difference below the threshold) 
%   and have a horizontal distance between their centroids below the distance threshold, 
%   and 0 otherwise.

num_lines = size(centroids, 1);
parallel_matrix = zeros(num_lines);  % Initialize the matrix with zeros

for i = 1:num_lines-1
    for j = i+1:num_lines
        % Check angle difference
        angle_diff = abs(angles(i) - angles(j));
        if angle_diff <= angle_threshold
            % Check ortogonal distance
            distance = distance_between_lines(centroids(i, :), angles(i), centroids(j, :), angles(j),0);
            if distance <= distance_threshold
                parallel_matrix(i, j) = 1;  % Mark the parallel pair
                parallel_matrix(j, i) = 1;  % Make the matrix symmetric
            end
        end
    end
end

end



function distance = distance_between_lines(centroid1, angle1, centroid2, angle2, plot_lines)
%DISTANCE_BETWEEN_LINES Calculates the shortest distance between two lines at their midpoint.
%   distance = DISTANCE_BETWEEN_LINES(centroid1, angle1, centroid2, angle2, plot_lines) 
%   takes the centroids (1x2 vectors) and angles (in degrees) of two lines as input,
%   and a boolean flag 'plot_lines'. It returns the shortest distance between the lines 
%   at the midpoint between their centroids. If 'plot_lines' is true, it also plots 
%   the lines, the midpoint, and a line indicating the distance.

% Calculate the midpoint between the centroids
midpoint = (centroid1 + centroid2) / 2;

% Calculate line equations (slope and intercept)
line1 = get_line_equation_from_centroid_and_angle(centroid1, angle1);
line2 = get_line_equation_from_centroid_and_angle(centroid2, angle2);

% Calculate y-coordinates on each line at the midpoint's x-coordinate
y1 = line1(1) * midpoint(1) + line1(2);
y2 = line2(1) * midpoint(1) + line2(2);

% Calculate x-coordinates on each line at the midpoint's y-coordinate
x1 = (midpoint(2) - line1(2)) / line1(1);
x2 = (midpoint(2) - line2(2)) / line2(1);

% Calculate both distances
distance_y = abs(y1 - y2);
distance_x = abs(x1 - x2);

% Choose the shortest distance
distance = min(distance_y, distance_x);

% Plot lines if requested
if plot_lines
    plot_lines_with_midpoint(centroid1, -angle1, centroid2, -angle2, midpoint,distance);
end

end

function line_eq = get_line_equation_from_centroid_and_angle(centroid, angle)
% Helper function to get line equation from centroid and angle
    slope = tan(angle * pi / 180); % Calculate slope from angle
    intercept = centroid(2) - slope * centroid(1); % Calculate intercept
    line_eq = [slope, intercept];
end


function plot_lines_with_midpoint(centroid1, angle1, centroid2, angle2, midpoint, distance)
%PLOT_LINES_WITH_MIDPOINT Plots two lines, their midpoint, and the distance between them.
%   plot_lines_with_midpoint(centroid1, angle1, centroid2, angle2, midpoint, distance)
%   takes the centroids, angles, midpoint, and distance between two lines as input
%   and generates a plot showing the lines, the midpoint, and a line indicating
%   the distance between the lines at the midpoint.

% Calculate line equations (slope and intercept)
line1 = get_line_equation_from_centroid_and_angle(centroid1, angle1);
line2 = get_line_equation_from_centroid_and_angle(centroid2, angle2);

% Generate x-coordinates for plotting
x_coords = [min(centroid1(1), centroid2(1)) - 50, max(centroid1(1), centroid2(1)) + 50]; 
% Calculate y-coordinates using line equations
y_coords1 = line1(1) * x_coords + line1(2);
y_coords2 = line2(1) * x_coords + line2(2);

% Calculate y-coordinates using line equations
% Calculate y-coordinates on each line at the midpoint's x-coordinate
y1 = line1(1) * midpoint(1) + line1(2);
y2 = line2(1) * midpoint(1) + line2(2);

% Calculate x-coordinates on each line at the midpoint's y-coordinate
x1 = (midpoint(2) - line1(2)) / line1(1);
x2 = (midpoint(2) - line2(2)) / line2(1);

% Calculate both distances
distance_y = abs(y1 - y2);
distance_x = abs(x1 - x2);


% Plot the lines
figure;
plot(x_coords, y_coords1, 'b-', 'LineWidth', 2); % Plot line 1 in blue
hold on;
plot(x_coords, y_coords2, 'r-', 'LineWidth', 2); % Plot line 2 in red
xlim([0 max([x1,x2])+50]);
ylim([0 max([y1,y2])+50]);


% Plot the distance line
if distance_x <= distance_y  % If x distance is shorter
    plot([x1, x2], [midpoint(2), midpoint(2)], 'k--', 'LineWidth', 1.5);
    text((x1 + x2) / 2 + 5, midpoint(2), num2str(distance), 'FontSize', 12);
else  % If y distance is shorter
    plot([midpoint(1), midpoint(1)], [y1, y2], 'k--', 'LineWidth', 1.5);
    text(midpoint(1) + 5, (y1 + y2) / 2, num2str(distance), 'FontSize', 12);
end

% Add labels and legend
xlabel('X');
ylabel('Y');
title('Lines and Midpoint');
legend('Line 1', 'Line 2', 'Distance');
hold off;

end