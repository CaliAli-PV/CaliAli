function o = bm_tern(c,a,b)
%% bm_tern: Pick one of two values.
%
% Inputs:
%   c, a, b - Condition and the two values.
%
% Outputs:
%   o - a if c, otherwise b.

if c, o = a; else, o = b; end
end
