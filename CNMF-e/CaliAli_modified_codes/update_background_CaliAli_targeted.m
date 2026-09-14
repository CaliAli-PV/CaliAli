function obj=update_background_CaliAli_targeted(obj, use_parallel, ret_id, frame_range)
%% update_background_CaliAli_targeted: Fit the background on one interval of frames.
%
% Identical to update_background_CaliAli in every respect except which frames
% the ring model is fitted on. Passing the whole recording as FRAME_RANGE gives
% numerically the same result as calling update_background_CaliAli directly,
% because it is the same code with the same batching.
%
% Used when sessions are added to an existing extraction: the background for the
% appended session has to be estimated from that session, not from an average
% over sessions whose background the earlier extraction already fitted.
%
% Inputs:
%   obj          - Sources2D object
%   use_parallel - parallel processing flag
%   ret_id       - retired components, as in update_background_CaliAli
%   frame_range  - [first last] frames to fit on
%
% Author: Pablo Vergara

if ~exist('ret_id','var'); ret_id=[]; end
if ~exist('frame_range','var') || isempty(frame_range)
    frame_range=[1, size(obj.C,2)];
end
obj=update_background_CaliAli(obj, use_parallel, ret_id, [], frame_range);
end
