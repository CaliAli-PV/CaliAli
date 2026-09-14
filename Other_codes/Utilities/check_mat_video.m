function [status, reason, nframes] = check_mat_video(file, expected_frames)
%% check_mat_video: Is this .mat a complete video, without loading it?
%
% Judges the CONTENT, not the file size. An interrupted write leaves a file
% whose Y is missing, not three-dimensional, unreadable, or whose last frame was
% never written; a size rule cannot see any of that, and misjudges both a small
% recording that is fine and a large one that was cut off half way.
%
% Nothing is loaded beyond a single frame. Dimensions come from the file's own
% metadata: h5info is the fast path, because a v7.3 .mat IS an HDF5 file, and
% matfile is the fallback for a v7 .mat, which is a different container that
% h5info cannot open. Measured on a 0.16 GB recording: h5info 0.079 s against
% matfile 0.334 s, plus 0.084 s for the last frame.
%
% Inputs:
%   file            - path to a .mat holding a variable Y
%   expected_frames - optional. When the caller knows how many frames the file
%                     should contain, this is checked exactly and "corrupt"
%                     stops being an inference.
%
% Outputs:
%   status  - 'ok', 'corrupt', or 'missing'
%   reason  - why, when status is not 'ok'
%   nframes - frames found, 0 when unknown
%
% This function never deletes anything. See remove_corrupted_output to act on
% the verdict, and report_corrupted_files to report it without acting.
%
% Author: Pablo Vergara

status = 'ok'; reason = ''; nframes = 0;
if nargin < 2, expected_frames = []; end
if iscell(file), file = file{1}; end
file = char(file);

if ~isfile(file)
    status = 'missing'; reason = 'file does not exist';
    return
end

%% ---- dimensions, from metadata only ------------------------------------
dims = []; via_h5 = false; m = [];
try
    inf_h5 = h5info(file, '/Y');
    dims = inf_h5.Dataspace.Size;
    via_h5 = true;
catch
    % not a v7.3 file, or no /Y dataset; fall through to matfile
end
if isempty(dims)
    try
        m = matfile(file);
        w = whos(m, 'Y');
        if ~isempty(w), dims = w.size; end
    catch ME
        status = 'corrupt';
        reason = sprintf('cannot be read: %s', ME.message);
        return
    end
end
if isempty(dims) || numel(dims) < 3 || dims(3) < 1
    status = 'corrupt';
    reason = 'Y is missing, is not 3-D, or has no frames';
    return
end
nframes = dims(3);

%% ---- exact check, when the caller knows the answer ---------------------
if ~isempty(expected_frames) && nframes ~= expected_frames
    status = 'corrupt';
    reason = sprintf('has %d frames, expected %d', nframes, expected_frames);
    return
end

%% ---- last frame: one partial read -------------------------------------
% A write cut off part way leaves the trailing frames as zeros, which is the
% one failure the dimensions cannot show.
try
    if via_h5
        last = h5read(file, '/Y', [1 1 nframes], [dims(1) dims(2) 1]);
    else
        last = m.Y(:, :, nframes);
    end
catch ME
    status = 'corrupt';
    reason = sprintf('last frame could not be read: %s', ME.message);
    return
end
if ~any(last(:))
    status = 'corrupt';
    reason = 'last frame is all zeros';
end
end
