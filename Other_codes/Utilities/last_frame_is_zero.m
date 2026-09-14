function [isZero, errMsg] = last_frame_is_zero(path)
%% last_frame_is_zero: Was this .mat video cut off before its last frame?
%
% A thin wrapper over check_mat_video, kept because several callers read more
% naturally as a yes/no question. There is one implementation of the check so
% the two cannot drift apart.
%
% Output:
%   isZero - true when the file is incomplete for ANY reason, not only a zero
%            last frame: Y missing, not 3-D, unreadable, or never finished
%   errMsg - why
%
% Author: Pablo Vergara

[status, reason] = check_mat_video(path);
isZero = strcmp(status, 'corrupt') || strcmp(status, 'missing');
errMsg = reason;
end
