function videoArray = loadGrayAVIwithFFmpeg(videoFile)
% Loads a compressed AVI video as a 3D grayscale array in MATLAB using FFmpeg.
%
% Arguments:
%   videoFile: Path to the AVI file.
%
% Returns:
%   videoArray: A 3D array (height × width × numFrames) of the grayscale video.

    % Check if the file exists
    if ~exist(videoFile, 'file')
        error('File does not exist: %s', videoFile);
    end

    % FFmpeg from the system, or downloaded the first time (caliali_tool)
    ffmpegPath = caliali_tool('ffmpeg');

    % Use FFmpeg to extract video metadata
    [~, ffmpegInfo] = run_quoted(sprintf('"%s" -nostdin -i "%s"', ffmpegPath, videoFile));

    % Extract video width and height
    resolutionPattern = 'Stream #.*: Video: .* (\d+)x(\d+)';
    resMatch = regexp(ffmpegInfo, resolutionPattern, 'tokens', 'once');
    if isempty(resMatch)
        error('Could not extract video resolution from FFmpeg output.');
    end
    width = str2double(resMatch{1});
    height = str2double(resMatch{2});

    % Extract frame rate (FPS)
    fpsPattern = '(\d+(?:\.\d+)?) fps';
    fpsMatch = regexp(ffmpegInfo, fpsPattern, 'tokens', 'once');
    if isempty(fpsMatch)
        error('Could not extract frame rate from FFmpeg output.');
    end
    fps = str2double(fpsMatch{1});

    % Extract video duration
    durationPattern = 'Duration: (\d+):(\d+):([\d.]+)';
    durationMatch = regexp(ffmpegInfo, durationPattern, 'tokens', 'once');
    if isempty(durationMatch)
        error('Could not extract video duration from FFmpeg output.');
    end
    hours = str2double(durationMatch{1});
    minutes = str2double(durationMatch{2});
    seconds = str2double(durationMatch{3});
    duration = hours * 3600 + minutes * 60 + seconds;

    % Estimate number of frames
    numFrames = round(duration * fps);

    % Define a temporary raw file for FFmpeg output
    rawFile = tempname; 

    % FFmpeg command to extract raw grayscale frames
    ffmpegCommand = sprintf('"%s" -nostdin -y -i "%s" -vf format=gray -f rawvideo -pix_fmt gray "%s"', ...
                            ffmpegPath, videoFile, rawFile);

    % Run FFmpeg
    [status, cmdout] = run_quoted(ffmpegCommand);
    if status ~= 0
        error('FFmpeg failed: %s', cmdout);
    end

    % Read raw grayscale data from the temporary file
    fileID = fopen(rawFile, 'rb');
    rawData = fread(fileID, inf, 'uint8');
    fclose(fileID);
    delete(rawFile);  % Remove temporary file

    % Validate that the raw data size matches expected dimensions
    expectedSize = width * height * numFrames;
    if length(rawData) < expectedSize
        warning('Extracted data is smaller than expected. Video may be truncated.');
        numFrames = floor(length(rawData) / (width * height));
    end

    % Reshape data into a 3D array (Height x Width x Frames)
    videoArray = reshape(rawData, [width, height, numFrames]);
    videoArray = permute(videoArray, [2, 1, 3]);  % Adjust dimensions to match MATLAB convention

    disp('Video loaded successfully.');
end


function [status, out] = run_quoted(cmd)
% cmd.exe drops the first and last quote of a line that starts with one.
if ispc
    cmd = ['"' cmd '"'];
end
[status, out] = system(cmd);
end
