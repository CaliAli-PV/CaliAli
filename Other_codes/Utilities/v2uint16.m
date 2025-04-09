function out = v2uint16(in, thr)
% v2uint16: Convert an input array to uint16 with optional thresholding and memory handling
%
% This function normalizes the input array `in` to the range [0, 1] and then
% scales it to uint16 format.

% Arguments:
%   - in: Input numeric array to be converted to uint16
%   - thr: (Optional) Two-element vector [lower, upper] specifying the thresholds.
%          Values below `thr(1)` are clamped to `thr(1)`, and values above `thr(2)`
%          are clamped to `thr(2)`.
%
% Returns:
%   - out: Normalized and converted array in uint16 format


% Process the entire array at once
in = single(in); % Convert to single precision for normalization
if exist('thr', 'var') % Apply thresholding if specified
    in(in < thr(1)) = thr(1);
    in(in > thr(2)) = thr(2);
end
% Normalize to the range [0, 1] and scale to uint16
in = (in - min(in, [], 'all')) ./ range(in, 'all');
out = uint16(in * 2^16); % Scale to 16-bit range
