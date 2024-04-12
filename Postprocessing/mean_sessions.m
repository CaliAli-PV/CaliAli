function out = mean_sessions(S)
% MEAN_SESSIONS Calculates the mean across sessions for each row in the input cell array.
%
% INPUT:
%   S: Cell array containing session data matrices.
%
% OUTPUT:
%   out: Matrix representing the mean across sessions for each row.

% Apply mean operation to each session independently and store results in a cell array
out = cellfun(@(a) mean(a, 2), S, 'UniformOutput', false);

% Concatenate cell array elements horizontally to form the final output matrix
out = catpad(2, [], out{:});
