function [b1, b2] = translation_bound_default(frame_size, fraction)
%% translation_bound_default: Border ignored when estimating the session shift.
%
% sessions_translate does not estimate the translation from the whole
% projection. It trims a border first, because the outer pixels of a session
% carry edge artifacts from motion correction and from the detrending filter,
% and a phase-correlation peak will happily lock onto a straight edge rather
% than onto the vessels.
%
% That border used to be a flat 20 pixels, 10 per side, whatever the recording
% was. A pixel count cannot mean the same thing on two frames of different size,
% and the frame size here is decided by spatial_ds: the same 20 pixels is 11% of
% a 180-row recording and 22% of the same recording downsampled by two. The
% smaller the frame, the larger the share of it that was thrown away -- exactly
% backwards, since a small frame has less to spare. On a 78x118 session it hid a
% quarter of the rows from the estimate.
%
% A fraction keeps the share fixed, but a fraction alone overshoots in the other
% direction: the artefact being avoided has a width in pixels, not a width in
% percent, so on a 512x512 recording a flat 20% would discard 51 pixels a side to
% find a shift of a few. The trim is therefore a share of the frame CAPPED in
% pixels, and the cap is the value the pipeline has always used. So this never
% trims MORE than before -- an axis of 100 pixels or more gets exactly the old 10
% pixels a side -- and only relaxes the axes that were being over-trimmed.
%
% Inputs:
%   frame_size - [d1 d2] of the projection being registered
%   fraction   - share of each axis to trim in total, half from each side.
%                Defaults to 0.2, so 10% per side.
%
% Outputs:
%   b1, b2 - TOTAL pixels to remove along each axis, always even so the trim is
%            symmetric and the centre of the image does not move.
%
% Author: Pablo Vergara

if nargin < 2 || isempty(fraction), fraction = 0.2; end

MIN_BOUND = 4;      % below this the trim stops doing anything useful
MAX_BOUND = 20;     % 10 px a side, the flat value this replaces
MAX_SHARE = 0.4;    % never hand the estimate less than 60% of an axis

b1 = clamp_bound(frame_size(1), fraction, MIN_BOUND, MAX_BOUND, MAX_SHARE);
b2 = clamp_bound(frame_size(2), fraction, MIN_BOUND, MAX_BOUND, MAX_SHARE);
end


function b = clamp_bound(d, fraction, min_bound, max_bound, max_share)
b = 2 * round(fraction * d / 2);            % even, so half comes off each side
b = min(b, max_bound);
b = max(b, min(min_bound, 2*floor((d-1)/2)));
b = min(b, 2 * floor(max_share * d / 2));   % a tiny frame keeps most of itself
b = max(b, 0);
end
