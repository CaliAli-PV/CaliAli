function t = bm_first_line(s)
s = char(s); nl = find(s==newline, 1);
if isempty(nl), t = s; else, t = s(1:nl-1); end
if numel(t) > 90, t = [t(1:87) '...']; end
end


%% ========================================================================
%  Metrics and the comparison between arms
%  ========================================================================
