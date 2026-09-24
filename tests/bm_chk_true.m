function c = bm_chk_true(name, cond, detail)
%% bm_chk_true: Record a check on a condition.
%
% Inputs:
%   name, cond, detail - Check name, the condition, a detail string.
%
% Outputs:
%   c - The check result.

c = struct('name',name,'pass',logical(cond),'detail',char(detail));
end
