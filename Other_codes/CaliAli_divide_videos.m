% CaliAli_divide_videos splits large video files into smaller segments based on a maximum number of frames.
% This is useful when individual sessions are too large to fit in memory.
% Each segment is saved as a new .mat file with an incremented suffix (_b1, _b2, etc.).
%
% INPUT:
%   max_frame - maximum number of frames per output file

function ses_id=CaliAli_divide_videos(max_frame)

% Prompt user to select .mat files to divide
opt.input_files = uipickfiles('FilterSpec', '*.mat');
ses_id=[];
% Loop through each selected file
for k = 1:length(opt.input_files)
    fullFileName = opt.input_files{k};
    fprintf(1, 'Now reading %s\n', fullFileName);

    % Extract file path and base name
    [filepath, name] = fileparts(fullFileName);

    % Load video data and options
    V = CaliAli_load(fullFileName, 'Y');
    CaliAli_options = CaliAli_load(fullFileName, 'CaliAli_options');

    % Determine frame split points based on max_frame
    F = round(linspace(0, size(V,3), round(size(V,3) / max_frame) + 1));

    % Save each segment as a new .mat file
    for j = 1:numel(F) - 1
        ses_id=[ses_id,k];
        output_file = strcat(filepath, filesep, name, '_b', num2str(j), '.mat');
        Y=V(:,:,F(j)+1:F(j+1));
        CaliAli_save(output_file,Y, CaliAli_options);
        fprintf(1, 'File saved in %s\n', output_file);
    end
end