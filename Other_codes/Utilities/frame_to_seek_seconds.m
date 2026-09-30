function t = frame_to_seek_seconds(frame_idx, fps)
%% frame_to_seek_seconds: Where in a video does frame N start?
%
% Used to build the -ss argument for ffmpeg, which seeks by TIME while the rest
% of the pipeline counts FRAMES.
%
% THE CAST IS THE WHOLE POINT. Frame indices arrive as integers, because that
% is what an index is, and in MATLAB int32/double is integer division with
% rounding: (int32(999))/25 is 40, not 39.96. Written inline as
% (frame_idx - 1)/fps, every seek was rounded to a whole second, so the reader
% silently returned frames up to half a second away from the ones asked for.
% Worse, on the last frame of a recording the rounding went UP, the seek landed
% exactly at the end of the video, ffmpeg returned nothing, and the caller got
% "Index in position 3 exceeds array bounds" from somewhere else entirely.
%
% This lives in its own function so the arithmetic can be tested anywhere. The
% reader that needs it only runs on macOS, which made it unreachable on the
% machine the benchmark runs on -- the defect above survived every scenario for
% exactly that reason.
%
% Inputs:
%   frame_idx - 1-based frame number, any numeric class
%   fps       - frames per second
%
% Outputs:
%   t - start time of that frame, in seconds
%
% Author: Pablo Vergara

t = (double(frame_idx) - 1) / double(fps);
end
