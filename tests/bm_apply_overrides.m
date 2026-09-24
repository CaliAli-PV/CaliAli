function opt = bm_apply_overrides(opt, pairs)
for i = 1:2:numel(pairs)
    parts = strsplit(pairs{i}, '.');
    opt.(parts{1}).(parts{2}) = pairs{i+1};
end
end
