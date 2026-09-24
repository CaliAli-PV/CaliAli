function c = bm_chk_true(name, cond, detail)
%% bm_chk_true: Record a check on a condition.
%
% Inputs:
%   name, cond, detail - Check name, the condition, a detail string.
%
% Outputs:
%   c - The check result.

% Forced to one value. A condition given as an array would otherwise make
% [results.pass] longer than the array of results, and every later use of it as
% a logical index fails somewhere far from here. Empty counts as failure.
c = struct('name',name,'pass',~isempty(cond) && all(logical(cond(:))), ...
    'detail',char(detail));
end
