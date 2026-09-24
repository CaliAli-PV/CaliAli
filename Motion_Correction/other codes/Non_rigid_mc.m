function [V, valid] = Non_rigid_mc(V, ref, opt)
%% Non_rigid_mc: Correct non-rigid motion with NoRMCorre, coarse to fine.
%
% Runs AFTER Rigid_mc, on data whose whole-frame translation has already been
% removed. What is left is deformation: parts of the field of view moving
% differently from each other. NoRMCorre handles that by splitting the frame
% into a grid of patches and giving each its own rigid shift, bounded by max_dev
% so a patch cannot depart far from the whole-frame one.
%
% ONE LEVEL BY DEFAULT, A PYRAMID ON REQUEST. non_rigid_levels = 1 lays 3
% patches across each axis and stops. Ask for more and each further level uses a
% finer grid -- 4, then 5, then 6 -- and registers only the residual the level
% before it left, with the reference recomputed from the corrected data each
% time.
%
% Measured on a simulated recording with a known 1.5 px rms deformation,
% reporting the misalignment left behind:
%
%   translation only                 1.240 px
%   3x3 alone                        0.802
%   4x4 alone                        0.850     a finer grid ALONE is worse
%   5x5 alone                        0.873
%   3x3 -> 4x4                       0.794
%   3x3 -> 4x4 -> 5x5                0.767
%   3x3 -> 4x4 -> 5x5 -> 6x6         0.713
%
% A finer grid on its own loses: each patch holds less signal and its estimate
% gets noisier. It only pays in a cascade, where the fine level has just a small
% residual left to find and its noise costs less than what it removes. Hence one
% coarse level as the default and the pyramid as something to opt into.
%
% WHAT THIS REPLACES. This function used to register with a KLT tracker: klt2
% calls detectMinEigenFeatures and vision.PointTracker, both from the Computer
% Vision Toolbox, which is not part of every licence. Where it is absent every
% call threw, a bare catch in get_trans_score turned each into NaN, and the
% failure surfaced later as interp1 complaining about sample points -- a message
% with nothing to do with the cause. NoRMCorre needs nothing beyond Image
% Processing, which the pipeline already requires.
%
% NO BORDER TRIM. Rigid_mc trims a border before estimating, to keep a
% whole-frame correlation off the frame edge. That cannot be done here: a
% piecewise shift is a field laid out on a grid, and the grid it is estimated on
% has to be the grid it is applied on. max_dev gives the same protection by
% another route.
%
% Inputs:
%   V   - the video, already translated by Rigid_mc
%   ref - the reference Rigid_mc used. Kept for the interface; this function
%         builds its own, because the vessel map that suits a whole-frame shift
%         is the wrong image for a patch. See highpass_reference.
%   opt - motion correction options. Reads non_rigid_levels and
%         non_rigid_highpass_sigma.
%
% Outputs:
%   V     - the warped video, same class and size
%   valid - logical [d1 d2], true where every level left real data. Derived by
%           putting a frame of ones through the SAME warps, so whatever happens
%           to the data happens to the mask and no pixel value is inspected.
%
% Author: Pablo Vergara

[d1, d2, ~] = size(V);
orig_class = class(V);

levels = 1;
if isfield(opt,'non_rigid_levels') && ~isempty(opt.non_rigid_levels)
    levels = max(1, round(opt.non_rigid_levels));
end
sigma = 6;
if isfield(opt,'non_rigid_highpass_sigma') && ~isempty(opt.non_rigid_highpass_sigma)
    sigma = opt.non_rigid_highpass_sigma;
end

if size(V,3) < 200, binz = size(V,3); else, binz = 200; end

W = single(V);                       % carried in floating point between levels,
valid = true(d1, d2);                % so repeated warps do not requantise
probe = ones(d1, d2, size(V,3), 'single');

for k = 1:levels
    npatch = k + 2;                  % level 1 is 3x3, level 2 is 4x4, ...
    [grid_size, mot_uf, max_dev, overlap_pre] = non_rigid_grid_default([d1 d2], npatch);

    % The reference is rebuilt from the CURRENT data, so a later level registers
    % what is left rather than re-estimating what an earlier one already removed.
    R = highpass_reference(W, sigma);

    options_nr = NoRMCorreSetParms('d1',d1,'d2',d2,'bin_width',binz, ...
        'max_shift',20,'iter',1,'correct_bidir',false, ...
        'grid_size',grid_size,'mot_uf',mot_uf,'max_dev',max_dev, ...
        'overlap_pre',overlap_pre,'overlap_post',overlap_pre, ...
        'shifts_method','cubic','boundary','nan', ...
        'use_windowing',true);
    % use_windowing tapers each patch before the transform. The correlation is
    % circular, so the patch's left edge sits next to its right edge and that
    % seam produces a spurious peak at zero shift -- which is the bias pulling
    % every estimate toward nothing. Tapering removes the seam, but only works
    % on an image that is already close to zero-mean, which is the other thing
    % the high pass is for.

    fprintf('Non-rigid level %d of %d: %dx%d patches over a %dx%d frame...\n', ...
        k, levels, npatch, npatch, d1, d2);
    tic; [~, shifts, ~] = normcorre_batch(R, options_nr); toc

    W     = apply_shifts(W, shifts, options_nr);
    probe = apply_shifts(probe, shifts, options_nr);

    % The warp fills what it pushes out of frame with NaN, and a NaN anywhere
    % makes the whole transform NaN at the next level -- the correlation peak
    % search then finds nothing and returns empty, which fails deeper in
    % dftregistration_min_max with a message about logical operands. The
    % validity of those pixels is carried by PROBE, so the data itself is
    % zeroed: after the high pass a constant region is exactly zero and
    % contributes nothing to the correlation, which is what is wanted.
    W(isnan(W)) = 0;
end

valid = all(probe >= 1 - 1e-4 & ~isnan(probe), 3);
W(isnan(W)) = 0;
V = cast(W, orig_class);
end
