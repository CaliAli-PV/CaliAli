function cls = bm_mat_class(f)
cls = '';
try
    if iscell(f), f = f{1}; end
    w = whos(matfile(char(f)),'Y');
    if ~isempty(w), cls = w.class; end
catch
end
end
