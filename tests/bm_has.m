function tf = bm_has(list, name)
%% bm_has: Is this name in the list?
%
% Inputs:
%   list, name - Cell array of names, and one name.
%
% Outputs:
%   tf - true or false.

tf = any(strcmp(list, name));
end
