function [grid_size, mot_uf, max_dev] = non_rigid_grid_default(frame_size, gSig, patch_scale)
%% non_rigid_grid_default: Patch geometry for piecewise-rigid motion correction.
%
% NoRMCorre corrects non-rigid motion by splitting the frame into patches and
% giving each its own rigid shift, bounded so it cannot stray far from the
% whole-frame shift. Three numbers decide it, and all three have to scale with
% the recording rather than being fixed pixel counts.
%
% GRID_SIZE. A patch has to be large enough to hold several neurons, or there is
% not enough structure in it to register and the estimate becomes noise. Neurons
% are gSig wide, so the patch is set as a multiple of gSig -- the same reasoning
% as patch_overlap_default and gSiz. It is then clamped so the frame is divided
% into at least two patches along each axis, since one patch is just rigid
% correction, and into no more than eight, since past that the patches are
% smaller than the structures they are meant to follow.
%
% MOT_UF. The shift field is estimated per patch and then upsampled to per pixel,
% so the correction varies smoothly instead of jumping at a patch boundary.
%
% MAX_DEV. How far a patch may depart from the whole-frame shift. This is what
% keeps a patch that happens to contain nothing from wandering off on noise.
%
% Inputs:
%   frame_size  - [d1 d2] of the recording
%   gSig        - neuron filter width, in pixels
%   patch_scale - patch side as a multiple of gSig. Defaults to 16, so a patch
%                 holds roughly four neurons across.
%
% Outputs:
%   grid_size - [rows cols 1] patch size for NoRMCorreSetParms
%   mot_uf    - [4 4 1] upsampling of the shift field
%   max_dev   - [3 3 1] allowed departure from the rigid shift, in pixels
%
% Author: Pablo Vergara

if nargin < 3 || isempty(patch_scale), patch_scale = 16; end
if isempty(gSig) || gSig <= 0, gSig = 5; end

MIN_PATCHES = 2;    % fewer than two is rigid correction by another name
MAX_PATCHES = 8;    % more than this and a patch is smaller than what it tracks

side = patch_scale * gSig;
g1 = clamp_side(frame_size(1), side, MIN_PATCHES, MAX_PATCHES);
g2 = clamp_side(frame_size(2), side, MIN_PATCHES, MAX_PATCHES);

grid_size = [g1, g2, 1];
mot_uf    = [4, 4, 1];
max_dev   = [3, 3, 1];
end


function g = clamp_side(d, side, min_patches, max_patches)
g = round(side);
g = min(g, floor(d / min_patches));   % at least this many patches across
g = max(g, ceil(d / max_patches));    % and at most this many
g = max(g, 8);                        % never smaller than a usable window
g = min(g, d);
end
