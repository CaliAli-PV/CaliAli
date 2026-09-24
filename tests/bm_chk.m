function c = bm_chk(name, got, want)
%% bm_chk: Record a check comparing a value against what was expected.
%
% Inputs:
%   name, got, want - Check name and the two values.
%
% Outputs:
%   c - The check result.

c = struct('name',name,'pass',isequal(got,want), ...
    'detail',sprintf('got %s, want %s', bm_tostr(got), bm_tostr(want)));
end
