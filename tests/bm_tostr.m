function s = bm_tostr(v)
if ischar(v), s = v; elseif isnumeric(v) || islogical(v), s = mat2str(v); else, s = class(v); end
end

%% ---- reporting ----------------------------------------------------------
