function bm_banner(t)
%% bm_banner: Print a section heading.
%
% Inputs:
%   t - The heading text.
%
% Outputs:
%   None.

fprintf('\n%s\n%s\n%s\n', repmat('=',1,72), t, repmat('=',1,72));
end
