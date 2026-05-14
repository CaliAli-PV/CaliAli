function [ret_id, active_id] = normalize_retired_ids(neuron, ret_id)
%% normalize_retired_ids - Validate retired component indices.
%
% ret_id uses current component indices, not neuron.ids values.

if nargin < 2 || isempty(ret_id)
    ret_id = [];
end

K = size(neuron.A, 2);
if K == 0 && ~isempty(neuron.C)
    K = size(neuron.C, 1);
end

if islogical(ret_id)
    if ~isvector(ret_id) || numel(ret_id) ~= K
        error('ret_id as a logical mask must be a vector with one entry per neuron.');
    end
    ret_id = find(ret_id);
end

if isempty(ret_id)
    ret_id = [];
    active_id = 1:K;
    return;
end

if ~isnumeric(ret_id) || ~isvector(ret_id)
    error('ret_id must be a numeric vector of current neuron indices.');
end

ret_id = unique(ret_id(:))';
if any(~isfinite(ret_id)) || any(ret_id ~= round(ret_id))
    error('ret_id must contain finite integer neuron indices.');
end
if any(ret_id < 1) || any(ret_id > K)
    error('ret_id contains indices outside the valid range 1:%d.', K);
end

active_id = setdiff(1:K, ret_id);
end
