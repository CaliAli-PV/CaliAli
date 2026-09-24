function v = bm_getfield_or(s, name, dflt)
%% bm_getfield_or: Read a field, or a default if it is missing.
%
% Inputs:
%   s, name, dflt - Structure, field name, fallback.
%
% Outputs:
%   v - The value or the fallback.

v = dflt;
try
    if isfield(s, name) && ~isempty(s.(name)), v = s.(name); end
catch
end
end


%% ========================================================================
%  Plumbing
%  ========================================================================
