function c = bm_chk_fail(name, detail)
%% bm_chk_fail: Record a check that could not be carried out.
%
% Inputs:
%   name, detail - Check name and why.
%
% Outputs:
%   c - The check result.

c = struct('name',name,'pass',false,'detail',char(detail));
end
