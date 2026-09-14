function A_ds = ring_active_support(A_block, nr_block, nc_block, bg_ssub, n_pixels)
%RING_ACTIVE_SUPPORT  Footprint support on the downsampled grid.
%
%   fit_ring_model builds its list of pixels to fit from sum(A,2)>0. When the
%   background is fitted on downsampled data, A must be downsampled the same
%   way or the pixel indices do not line up. Only the support matters, so one
%   column holding the summed footprints is enough, and the values themselves
%   are never used.
%
%   N_PIXELS is how many rows the downsampled data has. imresize rounds, so the
%   two can disagree by a pixel; when they do, return empty and let
%   fit_ring_model fall back to fitting every pixel. Skipping the wrong pixels
%   would be far worse than skipping none.
%
%   Author: Pablo Vergara

A_ds = [];
if isempty(A_block)
    return
end
supp = reshape(full(sum(A_block, 2)), nr_block, nc_block);
supp = imresize(supp, 1./bg_ssub, 'nearest');
supp = supp(:);
if nargin >= 5 && ~isempty(n_pixels) && numel(supp) ~= n_pixels
    return
end
A_ds = supp;
end
