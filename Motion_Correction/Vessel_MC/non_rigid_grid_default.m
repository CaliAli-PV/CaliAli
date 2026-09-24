function [grid_size, mot_uf, max_dev, overlap_pre] = non_rigid_grid_default(frame_size, npatch)
%% non_rigid_grid_default: NoRMCorre patch geometry for one pyramid level.
%
% NPATCH is how many patches to lay across each axis. Level 1 uses 3, level 2
% uses 4, and so on -- see Non_rigid_mc.
%
% THE OTHER THREE SCALE WITH THE PATCH, and getting that wrong is worse than
% getting the patch count wrong. NoRMCorre's defaults -- grid 128, overlap 32,
% max_dev 3 -- are a set of RATIOS written as pixel counts for one particular
% patch size. Change the grid and leave the rest alone and a 40 px patch reads
% 40 + 2*32 = 104 px: wider than the frame it sits in, so the patches are not
% local and cannot localise anything. Keeping the ratios instead gives a 40 px
% patch a 10 px overlap and 1 px of slack.
%
% Inputs:
%   frame_size - [d1 d2] of the recording
%   npatch     - patches per axis for this level
%
% Outputs:
%   grid_size   - [rows cols 1] patch size for NoRMCorreSetParms
%   mot_uf      - [4 4 1] upsampling of the shift field
%   max_dev     - allowed departure from the rigid shift, in pixels
%   overlap_pre - how far past its own edge a patch reads
%
% Author: Pablo Vergara

npatch = max(2, round(npatch));
g1 = max(8, ceil(frame_size(1)/npatch));
g2 = max(8, ceil(frame_size(2)/npatch));

grid_size = [g1, g2, 1];

OVERLAP_RATIO = 32/128;   % a patch reads a quarter of its own width past each edge
DEV_RATIO     =  3/128;   % and may depart from the rigid shift by this much

overlap_pre = [max(4, round(OVERLAP_RATIO*g1)), max(4, round(OVERLAP_RATIO*g2)), 1];
max_dev     = [max(1, round(DEV_RATIO*g1)),     max(1, round(DEV_RATIO*g2)),     1];
mot_uf      = [4, 4, 1];
end
