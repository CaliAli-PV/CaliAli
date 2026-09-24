function c = bm_chk_num(name, got, want, tol)
%% bm_chk_num: Record a numeric check with a tolerance.
%
% Inputs:
%   name, got, want, tol - Check name, the two values, tolerance.
%
% Outputs:
%   c - The check result.

c = struct('name',name,'pass',abs(double(got)-double(want)) <= tol, ...
    'detail',sprintf('got %g, want %g (tol %g)', got, want, tol));
end
