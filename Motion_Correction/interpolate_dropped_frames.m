function Mr=interpolate_dropped_frames(Mr, valid)
%% interpolate_dropped_frames: Replace frames the camera never delivered.
%
% A dropped frame arrives as all zeros. The test used to be
%
%     dropped = squeeze(mean(mean(Mr))) == 0;
%
% which could never fire, because Rigid_mc added 1 to every pixel before
% translating so that 0 could mean "border fill". A dropped frame therefore
% reached here as a frame of ones, and nothing was ever interpolated. Reported
% as the second half of issue #35; the reporter attributed it to the offset in
% the downsampling stage, but the offset in Rigid_mc applied on every path, so
% the test was dead no matter which downsampler produced the file.
%
% VALID (optional) is the logical mask of pixels holding real data. With it, a
% frame is judged on those pixels only, so border fill is not mistaken for a
% dropped frame and a frame that is entirely border is not mistaken for one
% either. Without it, every pixel is considered, which is the right reading for
% data that has not been through motion correction.
%
% The datatype is preserved. It used to be forced to uint8 or uint16, so a
% single recording came back as uint16.
%
% Author: Pablo Vergara

if nargin < 2, valid = []; end
orig_class = class(Mr);

if isempty(valid)
    frame_mean = squeeze(mean(mean(Mr, 1), 2));
else
    valid = logical(valid);
    if ~any(valid(:))
        return   % nothing is valid; there is no basis to judge a frame on
    end
    flat = reshape(Mr, [], size(Mr,3));
    frame_mean = mean(double(flat(valid(:), :)), 1)';
end

dropped = frame_mean == 0;
if ~any(dropped)
    return
end
if all(dropped)
    warning('CaliAli:AllFramesDropped', ...
        ['Every frame is empty, so there is nothing to interpolate from. ' ...
         'Check the recording before continuing.']);
    return
end

fprintf(1, 'There are %1.0f dropped frames  \n', sum(dropped));
fprintf(1, 'Fixing by interpolation... \n');
Mr = single(Mr);
Mr(:,:,dropped) = nan;
Mr = fillmissing(Mr, 'linear', 3);
Mr = cast(Mr, orig_class);
end
