function F = bm_read_frame(f, idx)
if iscell(f), f = f{1}; end
m = matfile(char(f));
F = m.Y(:,:,idx);
end
