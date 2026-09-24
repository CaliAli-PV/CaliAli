function c = bm_chk_num(name, got, want, tol)
%% bm_chk_num: Record a numeric check with a tolerance.
%
% Inputs:
%   name, got, want, tol - Check name, the two values, tolerance.
%
% Outputs:
%   c - The check result.

% Forced to one value, as in bm_chk_true. Comparing arrays here yields an array,
% which makes [results.pass] longer than the array of results and breaks every
% later use of it as a logical index -- in the report, far from here.
d = abs(double(got(:)) - double(want(:)));
c = struct('name',name,'pass',~isempty(d) && all(d <= tol), ...
    'detail',sprintf('got %s, want %s (tol %g)', bm_tostr(got), bm_tostr(want), tol));
end
