function neuron=update_temporal_CaliAli_targeted(neuron, use_parallel, frame_range)
%% update_temporal_CaliAli_targeted: Re-estimate traces on one interval of frames.
%
% Identical to update_temporal_CaliAli except that only FRAME_RANGE is
% re-estimated; traces outside it are carried through untouched. Passing the
% whole recording gives numerically the same result as calling
% update_temporal_CaliAli directly, because it is the same code with the same
% batching.
%
% WHAT THIS REPLACES. The previous version found the interval itself, as the
% frames whose traces were still NaN, and then rescaled the newly estimated
% block to match the retained one. Both existed because carried frames came
% from a finished extraction, in noise units, while new frames came straight
% out of HALS in movie units. Traces are now estimated for every frame by the
% same estimator before this runs (see initialize_traces_from_footprints), so
% there is no scale step to correct and no NaN block to detect: the interval is
% an argument.
%
% Inputs:
%   neuron       - Sources2D object
%   use_parallel - parallel processing flag
%   frame_range  - [first last] frames to re-estimate. Defaults to all frames.
%
% Author: Pablo Vergara

if ~exist('use_parallel','var') || isempty(use_parallel)
    use_parallel = neuron.use_parallel;
end
if ~exist('frame_range','var') || isempty(frame_range)
    frame_range = [1, size(neuron.C,2)];
end
fprintf('\n-----------------PROPAGATING COMPONENTS---------------------------\n');
neuron = update_temporal_CaliAli(neuron, use_parallel, [], [], frame_range);
end
