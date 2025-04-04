function frame = plot_P(P)
% frame=plot_P(P);
for i = 1:size(P,2)
    P.(i)(1,:).(1){1,1} = gray2rgb(P.(i)(1,:).(1){1,1});
    P.(i)(1,:).(2){1,1} = gray2rgb(P.(i)(1,:).(2){1,1}, 'bone');
    P.(i)(1,:).(3){1,1} = gray2rgb(P.(i)(1,:).(3){1,1}, 'hot');
    P.(i)(1,:).(5){1,1} = mat2gray(P.(i)(1,:).(5){1,1});
end
names = P.Properties.VariableNames;

% Create figure but keep it invisible to prevent real-time rendering
fig = figure('Visible', 'off'); 
set(fig, 'Position', [745 49.8 1247.2 828.8]);

for i = progress(1:size(P.(1)(1,:).(5){1,1}, 4))
    tiledlayout(size(P,2), 4, "TileSpacing", "compact");
    for j = 1:size(P,2)
        nexttile;
        imshow(P.(j)(1,:).(1){1,1}(:,:,:,i));
        if j == 1; title("Average frame"); end
        ylabel(names{1, j});

        nexttile;
        imshow(P.(j)(1,:).(2){1,1}(:,:,:,i));
        if j == 1; title("Blood Vessels"); end

        nexttile;
        imshow(P.(j)(1,:).(3){1,1}(:,:,:,i));
        if j == 1; title("Neurons"); end

        nexttile;
        imshow(P.(j)(1,:).(5){1,1}(:,:,:,i));
        if j == 1; title("BV+Neurons"); end
        plot_darkmode
    end

    % Capture frame without displaying it
    temp = getframe(fig);
    frame(:,:,:,i) = temp.cdata;

    % Prevent figure from updating in real-time
    drawnow limitrate;
end

% Close the figure to avoid unnecessary display
close(fig);

% Play the animation
implay(frame);