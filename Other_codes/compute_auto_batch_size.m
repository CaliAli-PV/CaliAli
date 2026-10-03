function [batch_sz, total_system_memory_GB] = compute_auto_batch_size(batch_sz,filename,d)
%% compute_auto_batch_size: Turn a batch_sz setting into frames per batch.
%
% Accepts the named modes as well as a plain number. Returns a number, where 0
% keeps its long-standing meaning for the callers of this function: do not split,
% take the file in one piece. 'all_frames' and 'per_session' both give 0 here,
% because every caller of this function works one file at a time and at that
% point in the pipeline one file is one session. Only get_batch_size, which runs
% after the sessions have been concatenated, has to tell those two apart, and it
% asks resolve_batch_mode directly.
%
% Inputs:
%   batch_sz - a positive number of frames, or 'auto', 'all_frames',
%              'per_session'. 0 is still accepted and still means all frames.
%   filename - file to read the frame size from, when 'auto' and D is absent
%   d        - [d1 d2] frame size, to avoid touching the file
%
% Outputs:
%   batch_sz               - frames per batch, 0 meaning "no splitting"
%   total_system_memory_GB - 0 unless 'auto' had to measure it
%
% Author: Pablo Vergara

total_system_memory_GB=0;

[mode, n] = resolve_batch_mode(batch_sz);
switch mode
    case 'fixed'
        batch_sz = n;
        return
    case {'all_frames','per_session'}
        batch_sz = 0;
        return
end

% 'auto': size the batch against the memory this machine actually has.
if ~exist("d","var") || isempty(d)
    f=h5info(filename);
    d = f.Datasets(strcmp({f.Datasets.Name}, 'Y')).Dataspace.Size(1:2);
end

try
    [total_system_memory_GB, free_system_memory_GB] = getSystemMemory;
catch
    cprintf('*red','Total physical memory could not be determined.\n');
    cprintf('red','Avilable memory was set to 18GB by default.\n');
    total_system_memory_GB = 18;
    free_system_memory_GB = Inf;   % unknown: do not cap
end

if total_system_memory_GB <= 8
    cprintf('*red','Detected %.1f GB RAM. CaliAli recommends at least 16 GB for automatic batch sizing.\n', total_system_memory_GB);
end
% 2e7 pixels per GB of TOTAL memory, i.e. about 54 bytes per pixel.
batch_sz = floor((total_system_memory_GB*2*10^7)/(d(1)*d(2))/100)*100;

% That ignores what else is running, and the pool workers. Cap it at what FREE
% memory holds at the measured cost: during alignment (get_projections_and_detrend)
% this MATLAB plus its pool workers peak at 55-69 bytes per pixel above the
% idle pool, at 4 and 16 workers and 1000-2000 frames. 20 bytes per pixel is
% the main process alone. The cap only ever makes the batch smaller.
fit = floor((free_system_memory_GB - 1.68)*2^30/(70*d(1)*d(2))/100)*100;
if fit < batch_sz
    batch_sz = fit;
    cprintf('-comment','Batch size capped by the %.1f GB of free RAM.\n', free_system_memory_GB);
end
% 0 means "do not split", the opposite of what a machine short of memory needs.
batch_sz = max(batch_sz, 100);
cprintf('-comment','Automatically set batch size to %d frames based on %.1f GB RAM and (%dx%d ) frame size.\n', ...
    batch_sz, total_system_memory_GB,d(1),d(2));

end
