function opt = bm_apply_overrides(opt, pairs)
%% bm_apply_overrides: Apply a scenario's option overrides.
%
% Inputs:
%   opt, pairs - Options and dotted name/value pairs.
%
% Outputs:
%   opt - The options with the overrides applied.

for i = 1:2:numel(pairs)
    parts = strsplit(pairs{i}, '.');
    opt.(parts{1}).(parts{2}) = pairs{i+1};
end
end
