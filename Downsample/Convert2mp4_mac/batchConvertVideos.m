function batchConvertVideos(fileList, outputFolder)
% Converts a list of AVI files to lossless grayscale MP4 files using FFmpeg.
% FFmpeg comes from caliali_tool, which finds it on the system or downloads
% it the first time. The output MP4 files will have a single grayscale
% channel (not RGB).
%
% Arguments:
%   fileList: A cell array of input AVI file paths.
%   outputFolder: The directory to save the converted files.
if ~exist('fileList','var')
    fileList = uipickfiles('REFilter','\.avi$|\.m4v$|\.mp4$|\.tif$|\.tiff$|\.isxd$');
end
ffmpegPath = caliali_tool('ffmpeg');

% Create the output folder if it doesn't exist
if exist('outputFolder','var')
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
end

% Loop through the file list
for i = 1:length(fileList)
    filePath = fileList{i};

    % Extract filename without extension

    if ~exist('outputFolder','var')
        [outputFolder,~, ~] = fileparts(filePath);
    end

    [~, fileName, ~] = fileparts(filePath);

    % Construct the FFmpeg command (lossless MP4, single grayscale channel)
    outputPath = fullfile(outputFolder, [fileName, '.mp4']);
    command = sprintf('"%s" -nostdin -y -i "%s" -vcodec libx264 -crf 0 -vf format=gray -pix_fmt gray "%s"', ...
        ffmpegPath, filePath, outputPath);
    if ispc
        command = ['"' command '"'];   % cmd.exe drops the outer pair of quotes
    end

    % Execute the command
    [status, output] = system(command);
    if status ~= 0
        error(['Error converting file: ', filePath, newline, output]);
    end

    disp(['Converted: ', filePath, ' to ', outputPath]);
end

disp('Batch conversion complete!');
end