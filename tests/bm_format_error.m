function s = bm_format_error(ME)
%% bm_format_error: Render an exception as a message with its stack.
%
% Inputs:
%   ME - The exception.
%
% Outputs:
%   s - The formatted text.

s = ME.message;
for i = 1:numel(ME.stack)
    s = sprintf('%s\n    at %s line %d', s, ME.stack(i).name, ME.stack(i).line);
end
end

%% ---- check constructors -------------------------------------------------
