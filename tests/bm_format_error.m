function s = bm_format_error(ME)
s = ME.message;
for i = 1:numel(ME.stack)
    s = sprintf('%s\n    at %s line %d', s, ME.stack(i).name, ME.stack(i).line);
end
end

%% ---- check constructors -------------------------------------------------
