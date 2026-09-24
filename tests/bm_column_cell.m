function c = bm_column_cell(x)
if ~iscell(x), x = {x}; end
c = x(:);
end
