function [mode, n] = resolve_batch_mode(batch_sz, zero_means)
%% resolve_batch_mode: Read a batch_sz setting and say what it is asking for.
%
% batch_sz used to be a number, and the number 0 carried a meaning that was not
% the same in every module: in downsampling and motion correction it meant "load
% the whole file at once", while in inter-session alignment and CNMF-E it meant
% "one batch per session". Two behaviours behind one value, with nothing in the
% value to tell them apart. The named modes say which one is wanted:
%
%   'auto'         pick a size from the free memory and the frame size
%   'all_frames'   one batch holding the whole recording
%   'per_session'  one batch per session, so batches follow session boundaries
%   <positive n>   n frames per batch
%
% 0 still works, and still means what it meant in the module that reads it. That
% is what ZERO_MEANS is for: the caller states which of the two legacy readings
% applies to it. Old option structs and old scripts therefore keep running.
%
% Inputs:
%   batch_sz   - the setting, a number or one of the mode names
%   zero_means - reading for a legacy 0, 'all_frames' (default) or 'per_session'
%
% Outputs:
%   mode - 'auto', 'all_frames', 'per_session' or 'fixed'
%   n    - frames per batch when mode is 'fixed', otherwise []
%
% Note: only 'per_session' needs to reach a consumer that knows where the
% sessions start, which is get_batch_size. Every file-level consumer treats
% 'per_session' and 'all_frames' alike, because at that point in the pipeline one
% file IS one session.
%
% Author: Pablo Vergara

if nargin < 2 || isempty(zero_means)
    zero_means = 'all_frames';
end

n = [];

if isstring(batch_sz) && isscalar(batch_sz)
    batch_sz = char(batch_sz);
end

if ischar(batch_sz)
    switch lower(strtrim(batch_sz))
        case 'auto',        mode = 'auto';
        case 'all_frames',  mode = 'all_frames';
        case 'per_session', mode = 'per_session';
        otherwise
            error('CaliAli:BatchMode:unknown', ...
                ['batch_sz "%s" is not a recognised mode. Use a positive number ' ...
                 'of frames, or one of: auto, all_frames, per_session.'], batch_sz);
    end
    return
end

if ~(isnumeric(batch_sz) && isscalar(batch_sz))
    error('CaliAli:BatchMode:unknown', ...
        ['batch_sz must be a positive number of frames, or one of: ' ...
         'auto, all_frames, per_session.']);
end

if isinf(batch_sz) || batch_sz <= 0
    mode = lower(char(zero_means));   % the legacy reading for this module
    return
end

mode = 'fixed';
n = ceil(batch_sz);
end
