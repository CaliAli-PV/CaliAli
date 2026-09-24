function s = bm_tostr(v)
%% bm_tostr: Render a value as a short string.
%
% Inputs:
%   v - Anything.
%
% Outputs:
%   s - Its string form.

if ischar(v), s = v; elseif isnumeric(v) || islogical(v), s = mat2str(v); else, s = class(v); end
end

%% ---- reporting ----------------------------------------------------------
