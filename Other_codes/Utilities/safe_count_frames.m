function n_frames = safe_count_frames(path)
%% safe_count_frames: Number of frames (size of dim 3 of Y) in a .mat video file.
%
% Reads only file metadata (via matfile/whos), never the pixel data, so it is
% cheap even for multi-GB files. Returns 0 when the file is missing,
% unreadable, or does not contain a 3-D variable Y.
%
% Shared safeguard helper: mirrors the frame-count check used by the
% inter-session alignment so that downsampling / concatenation can validate
% cached outputs without re-reading the video.
%
% Author: Pablo Vergara

try
    m = matfile(path);
    info = whos(m, 'Y');
    if isempty(info) || numel(info.size) < 3
        n_frames = 0;
    else
        n_frames = info.size(3);
    end
catch
    n_frames = 0;
end
end
