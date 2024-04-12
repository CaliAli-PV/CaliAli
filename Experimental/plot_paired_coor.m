function plot_paired_coor(c1,c2)

% Scatter plot
figure;
scatter(c1(:, 1), c1(:, 2), 'ro', 'DisplayName', 'Dataset 1');
hold on;
scatter(c2(:, 1), c2(:, 2), 'bx', 'DisplayName', 'Dataset 2');

% Connect corresponding points with lines
for i = 1:size(c1, 1)
    plot([c1(i, 1), c2(i, 1)], [c1(i, 2), c2(i, 2)], 'k-');
end

hold off;

% Set labels and legend
xlabel('X-axis');
ylabel('Y-axis');
title('Scatter Plot with Connecting Lines');

% Adjust the aspect ratio for better visualization (optional)
axis equal;