function v = bm_getfield_or(s, name, dflt)
v = dflt;
try
    if isfield(s, name) && ~isempty(s.(name)), v = s.(name); end
catch
end
end


%% ========================================================================
%  Plumbing
%  ========================================================================
