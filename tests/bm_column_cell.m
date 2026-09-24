function c = bm_column_cell(x)
%% bm_column_cell: Return the input as a column cell array.
%
% Inputs:
%   x - Anything.
%
% Outputs:
%   c - Column cell array.

if ~iscell(x), x = {x}; end
c = x(:);
end
