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
    if numel(parts) == 1
        % A flat name is a pipeline-wide setting and belongs at the top level.
        % Only dotted names were handled before, so asking for one -- which is
        % the only way to reach every module -- indexed past the end of parts.
        opt.(parts{1}) = pairs{i+1};
    else
        opt.(parts{1}).(parts{2}) = pairs{i+1};
    end
end
end
