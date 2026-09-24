function s = bm_escape(p)
%% bm_escape: Quote a path for a shell command.
%
% Inputs:
%   p - The path.
%
% Outputs:
%   s - The quoted path.

s = ['"' char(p) '"'];
end
