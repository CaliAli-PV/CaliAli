function [Mask, rows, cols] = largest_valid_rectangle(valid)
%% largest_valid_rectangle: The biggest rectangle in which every pixel is real.
%
% VALID is a logical image, true where the pixel holds real data. A warped or
% translated validity mask is RAGGED at the edges -- a non-rigid field makes the
% boundary follow the deformation -- so it cannot be cut out of a video directly:
% a video has to be a rectangle. This reduces it to the largest rectangle that is
% valid everywhere, which is the shape the rest of the pipeline can actually use.
%
% That rectangle is also what makes the crop arithmetic work. apply_translations
% and apply_NR_shifts select the mask's pixels in linear order and reshape the
% result to max(sum(Mask,1)) by max(sum(Mask,2)). Those two numbers multiply back
% to nnz(Mask) only when the mask is a rectangle; for any other shape the reshape
% either errors or, worse, succeeds and scrambles the frame.
%
% Inputs:
%   valid - logical image, true where the pixel is real
%
% Outputs:
%   Mask       - logical, same size as VALID, true on the largest valid rectangle
%   rows, cols - the indices that rectangle spans, for cropping directly
%
% Author: Pablo Vergara

valid = logical(valid);
[d1, d2] = size(valid);

% The border ring is held invalid on purpose: FindLargestRectangles returns a
% degenerate one-pixel strip when handed a mask with no invalid pixel at all.
N = false(d1+2, d2+2);
N(2:d1+1, 2:d2+1) = valid;

[~, ~, ~, M] = FindLargestRectangles(N);
Mask = logical(M(2:end-1, 2:end-1));

rows = find(any(Mask, 2))';
cols = find(any(Mask, 1))';

if isempty(rows) || isempty(cols)
    error('CaliAli:validRectangle:empty', ...
        ['No pixel is valid in every frame. The sessions have no overlap left ' ...
         'after the shifts, which usually means a shift was estimated wrongly.']);
end
end
