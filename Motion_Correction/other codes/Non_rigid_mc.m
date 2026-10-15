function [V, valid] = Non_rigid_mc(V, ref, opt, valid_in)
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
% ONLY THE REGION VALID IN EVERY FRAME. Rigid_mc fills what its translation
% shifts in with 0, and those edges move with every frame. 8 of the 9 patches
% touch a border, so they registered the moving edge: on static frames with
% borders moving by 4 px rms the patch shifts varied by 0.98 px rms where they
% should not move at all, against 0.08 px without the borders, and the harm grew
% with how much a session shook. Given the region Rigid_mc left valid, the warp
% is now estimated AND applied inside the largest rectangle valid in every
% frame, so the grid it is estimated on is the grid it is applied on, and the
% same frames give 0.16 px. Everything outside that rectangle is marked invalid;
% the crop that follows motion correction discards it anyway.
%
% Inputs:
%   V   - the video, already translated by Rigid_mc
%   ref - the reference Rigid_mc used. Kept for the interface; this function
%         builds its own, because the vessel map that suits a whole-frame shift
%         is the wrong image for a patch. See highpass_reference.
%   opt - motion correction options. Reads non_rigid_levels and
%         non_rigid_highpass_sigma.
%   valid_in - optional logical [d1 d2], the region Rigid_mc left valid in
%         every frame. Without it the whole frame is used, as before.
%
% Outputs:
%   V     - the warped video, same class and size
%   valid - logical [d1 d2], true inside the rectangle every level left real
%           data in. Derived by putting a frame of ones through the SAME warps,
%           so whatever happens to the data happens to the mask and no pixel
%           value is inspected. Outside it V keeps what it was given.
%
% Author: Pablo Vergara

if nargin >= 4 && ~isempty(valid_in) && ~all(valid_in(:))
    [~, rows, cols] = largest_valid_rectangle(valid_in);
    [Vc, valid_c] = Non_rigid_mc(V(rows, cols, :), ref, opt);
    V(rows, cols, :) = Vc;
    valid = false(size(valid_in));
    valid(rows, cols) = valid_c;
    return
end

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
                                     % so repeated warps do not requantise
rows = 1:d1;                         % the part of the frame W covers; it shrinks
cols = 1:d2;                         % after every level, see the end of the loop

% NoRMCorre picks the frames for its first template at random from MATLAB's
% global stream (randperm in normcorre_batch), so without a fixed seed the
% correction depended on whatever had drawn random numbers earlier in the
% session. Each level starts from the same seed; the caller's random state is
% put back afterwards.
prev_rng = rng;
restore_rng = onCleanup(@() rng(prev_rng)); %#ok<NASGU>
for k = 1:levels
    npatch = k + 2;                  % level 1 is 3x3, level 2 is 4x4, ...
    [w1, w2, ~] = size(W);
    [grid_size, mot_uf, max_dev, overlap_pre] = non_rigid_grid_default([w1 w2], npatch);

    % The reference is rebuilt from the CURRENT data, so a later level registers
    % what is left rather than re-estimating what an earlier one already removed.
    R = highpass_reference(W, sigma);

    options_nr = NoRMCorreSetParms('d1',w1,'d2',w2,'bin_width',binz, ...
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
    options_nr.max_shift(1:2) = min(options_nr.max_shift(1:2), ...
        patch_shift_limit(grid_size, mot_uf, overlap_pre, [w1 w2], options_nr.min_patch_size));

    fprintf('Non-rigid level %d of %d: %dx%d patches over a %dx%d frame...\n', ...
        k, levels, npatch, npatch, w1, w2);
    rng(0, 'twister');
    tic; [~, shifts, ~] = normcorre_batch(R, options_nr); toc

    W     = apply_shifts(W, shifts, options_nr);
    probe = apply_shifts(ones(w1, w2, size(W,3), 'single'), shifts, options_nr);

    % KEEP ONLY WHAT EVERY FRAME STILL HOLDS. The warp fills what it pushes out
    % of frame, and those edges move with every frame, exactly like the borders
    % the rigid stage leaves. Left in, the next level registered them: on a
    % recording with no deformation the 4x4 level's shifts varied by 0.79 to
    % 0.86 px rms and the motion left rose from 0.14 to 0.49 px, and with a
    % 1.5 px deformation the level failed inside dftregistration_min_max. So
    % the data is cut to the largest rectangle that is real in every frame
    % before the next level sees it. PROBE, a frame of ones put through the
    % SAME warp, says which pixels those are, so no pixel value is inspected.
    [~, r, c] = largest_valid_rectangle(all(probe >= 1 - 1e-4 & ~isnan(probe), 3));
    W = W(r, c, :);
    rows = rows(r);
    cols = cols(c);
end

valid = false(d1, d2);
valid(rows, cols) = true;
V(rows, cols, :) = cast(W, orig_class);
end


function lim = patch_shift_limit(grid_size, mot_uf, overlap, frame_size, min_patch_size)
%% The largest whole-frame shift every patch of this grid can still represent.
%
% NoRMCorre first registers the whole frame, within max_shift, and then searches
% each patch within max_dev of that shift. A patch n pixels across represents
% shifts of about n/2 at most. When the whole-frame shift lies beyond that, the
% patch's search window holds nothing, the peak search comes back empty, and
% normcorre_batch fails inside dftups ("Arrays have incompatible sizes"). It did
% on a simulated recording with a 6 px deformation whose rigid correction had
% left a few frames 20 to 30 px off. Capping max_shift at what the smallest
% patch represents keeps every window non-empty; on a recording rigid correction
% handled, the residual shift is far below the cap and nothing changes.
[xs, xf, ys, yf] = construct_grid(grid_size, mot_uf, frame_size(1), frame_size(2), 1, min_patch_size);
n1 = min(min(xf + overlap(1), frame_size(1)) - max(xs - overlap(1), 1) + 1);
n2 = min(min(yf + overlap(2), frame_size(2)) - max(ys - overlap(2), 1) + 1);
lim = max(1, floor([n1 n2]/2) - 1);
end
