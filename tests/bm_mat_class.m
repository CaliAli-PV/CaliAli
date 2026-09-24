function cls = bm_mat_class(f)
%% bm_mat_class: The class Y is stored in, from the file's metadata.
%
% Inputs:
%   f - Path to a .mat file.
%
% Outputs:
%   cls - Class name, empty if unreadable.

cls = '';
try
    if iscell(f), f = f{1}; end
    w = whos(matfile(char(f)),'Y');
    if ~isempty(w), cls = w.class; end
catch
end
end
