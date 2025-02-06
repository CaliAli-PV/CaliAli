function neuron = delete_circular(show,neuron, ratio_threshold)
% Filters out components from a neuron structure based on their width-to-length ratio.
%
% Args:
%   neuron:          A structure containing neuron data, including spatial components (neuron.A).
%   ratio_threshold: The minimum width-to-length ratio. Components with a ratio BELOW this value will be deleted
%                    (i.e., components that are too narrow relative to their length).
%
% Returns:
%   neuron: The updated neuron structure with filtered components removed.

A = neuron.A; % Get the spatial components.

% Preallocate arrays for major and minor axis lengths:
numComponents = size(A, 2);
lengths = zeros(1, numComponents);
widths = zeros(1, numComponents);

% Calculate major and minor axis lengths for each component:
for i = 1:numComponents
    % Binarize the component's footprint:
    binaryComponent = full(reshape(A(:, i), neuron.options.d1, neuron.options.d2)) > 0;
   
    [lengths(i), widths(i), ~, ~] = analyzeBlob(binaryComponent,0);
end

% Calculate the length-to-width ratios:
ratios =  lengths./widths;

% Find the indices of components to be deleted:
ix = ratios < ratio_threshold;

% Delete the components:
if show
    neuron.viewNeurons(find(ix), neuron.C_raw);
else
    neuron.delete(ix);
end

end


function [length, width, principalComponents, centroid] = analyzeBlob(binaryComponent,plotme)
% Analyzes a binary object to estimate its length and width using PCA.
%
% Args:
%   binaryImage: The binary image containing the object.
%
% Returns:
%   length:            Estimated length of the object (along the first principal component).
%   width:             Estimated width of the object (along the second principal component).
%   principalComponents: A 2x2 matrix where each column is a principal component (eigenvector).
%   centroid:          The centroid (center) of the object [x, y].

% 1. Find coordinates of all non-zero pixels (object pixels)
[rows, cols] = find(binaryComponent);
points = [cols, rows]; % [x, y] coordinates

% 2. Calculate the centroid (center) of the object
centroid = mean(points);

% 3. Center the points around the centroid
centeredPoints = points - centroid;

% 4. Perform PCA
coeff = pca(centeredPoints); % 'coeff' contains the principal components

% 5. Extract principal components
principalComponents = coeff(:, 1:2); % First two columns are the principal components

% 6. Project the centered points onto the principal components
projectedPoints = centeredPoints * principalComponents;

% 7. Calculate the ranges along the principal components to estimate length and width
minProj1 = min(projectedPoints(:, 1));
maxProj1 = max(projectedPoints(:, 1));
minProj2 = min(projectedPoints(:, 2));
maxProj2 = max(projectedPoints(:, 2));

length = maxProj1 - minProj1;
width = maxProj2 - minProj2;

% --- Optional: Visualization ---
if plotme
    figure;
    imshow(binaryComponent);
    hold on;

    % Plot the centroid
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);

    % Plot the principal axes
    quiver(centroid(1), centroid(2), principalComponents(1, 1) * length / 2, principalComponents(2, 1) * length / 2, 0, 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
    quiver(centroid(1), centroid(2), -principalComponents(1, 1) * length / 2, -principalComponents(2, 1) * length / 2, 0, 'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
    quiver(centroid(1), centroid(2), principalComponents(1, 2) * width / 2, principalComponents(2, 2) * width / 2, 0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
    quiver(centroid(1), centroid(2), -principalComponents(1, 2) * width / 2, -principalComponents(2, 2) * width / 2, 0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);


    legend('Centroid', 'Length (PC1)', '', 'Width (PC2)');
    hold off;
end

end