function Y = repair_frames(Y, report)
%% repair_frames: Apply the repairs a scan found, to one chunk of frames.
%
% The masks come from find_frame_defects, which decided them ONCE for the whole
% recording. This only applies them, so every chunk is treated identically and no
% seam appears where one batch ends and the next begins.
%
% Order matters. A dropped frame is empty, so every pixel in it looks dead; if
% pixels were judged or patched first, a dropped frame would drag the whole
% sensor into the repair. Frames are fixed first, then pixels.
%
% Inputs:
%   Y      - [d1 d2 t] chunk, in its original class
%   report - from find_frame_defects: rows, cols, dead
%
% Outputs:
%   Y      - repaired chunk, same class, cropped to report.rows/cols
%
% Author: Pablo Vergara

if isempty(Y), return; end
orig_class = class(Y);

%% 1. crop the border the scan found
if isfield(report,'rows') && ~isempty(report.rows)
    Y = Y(report.rows, report.cols, :);
end

%% 2. dropped frames, rebuilt from their neighbours in time
Y = interpolate_dropped_frames(Y);

%% 3. dead pixels, rebuilt from their neighbours in space
if isfield(report,'dead') && any(report.dead(:))
    dead = report.dead;
    if ~isequal(size(dead), [size(Y,1), size(Y,2)])
        return   % the mask does not belong to this data; leave it alone
    end
    Y = double(Y);
    % A defect is isolated by construction, so the mean of the live pixels
    % around it is a better estimate than anything more elaborate, and it cannot
    % pull in another defect.
    live = ~dead;
    for t = 1:size(Y,3)
        f = Y(:,:,t);
        num = conv2(f .* live, ones(3), 'same');
        den = conv2(double(live),  ones(3), 'same');
        filled = num ./ max(den, 1);
        f(dead) = filled(dead);
        Y(:,:,t) = f;
    end
    Y = cast(Y, orig_class);
end
end
