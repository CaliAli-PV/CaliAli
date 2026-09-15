function [V, valid] = Non_rigid_mc(V, ref, opt)
%% Non_rigid_mc: Correct non-rigid motion with NoRMCorre in grid mode.
%
% Runs AFTER Rigid_mc, on data whose whole-frame translation has already been
% removed. What is left is deformation: parts of the field of view moving
% differently from each other. NoRMCorre handles that by splitting the frame into
% a grid of patches and giving each its own rigid shift, bounded by max_dev so a
% patch cannot depart far from the whole-frame one, then upsampling those shifts
% into a smooth per-pixel field.
%
% WHAT THIS REPLACES. This function used to register with a KLT tracker: klt2
% calls detectMinEigenFeatures and vision.PointTracker, both from the Computer
% Vision Toolbox. Where that toolbox is absent -- and it is not part of every
% licence -- every call threw, a bare catch in get_trans_score turned each into
% NaN, and the failure surfaced much later as interp1 complaining that
% interpolation needs two sample points, a message with nothing to do with the
% cause. NoRMCorre needs nothing beyond Image Processing, which the pipeline
% already requires, and it is the same library the translation stage uses.
%
% NO BORDER TRIM. Rigid_mc trims a border before estimating, to keep a
% whole-frame phase correlation off the frame edge. That cannot be done here: a
% piecewise shift is a field laid out on a grid, and the grid it is estimated on
% has to be the grid it is applied on. max_dev gives the same protection by
% another route -- an edge patch with nothing in it still cannot wander more than
% a few pixels from the whole-frame shift.
%
% Inputs:
%   V   - the video, already translated by Rigid_mc
%   ref - the reference projection, already translated by Rigid_mc
%   opt - motion correction options. Reads gSig and non_rigid_patch_scale.
%
% Outputs:
%   V     - the warped video, same class and size
%   valid - logical [d1 d2], true where the warp left real data. Derived by
%           putting a frame of ones through the SAME call, so whatever happens to
%           the data happens to the mask and no pixel value is ever inspected.
%
% Author: Pablo Vergara

[d1, d2, ~] = size(ref);

scale = 16;
if isfield(opt,'non_rigid_patch_scale') && ~isempty(opt.non_rigid_patch_scale)
    scale = opt.non_rigid_patch_scale;
end
gSig = 5;
if isfield(opt,'gSig') && ~isempty(opt.gSig), gSig = opt.gSig; end

[grid_size, mot_uf, max_dev] = non_rigid_grid_default([d1, d2], gSig, scale);

if size(V,3) < 200
    binz = size(V,3);
else
    binz = 200;
end

options_nr = NoRMCorreSetParms('d1',d1,'d2',d2,'bin_width',binz, ...
    'max_shift',20,'iter',1,'correct_bidir',false, ...
    'grid_size',grid_size,'mot_uf',mot_uf,'max_dev',max_dev, ...
    'shifts_method','fft','boundary','nan');

fprintf('Applying non-rigid motion correction: %dx%d patches over a %dx%d frame...\n', ...
    ceil(d1/grid_size(1)), ceil(d2/grid_size(2)), d1, d2);

tic; [~, shifts, ~] = normcorre_batch(single(ref), options_nr); toc

orig_class = class(V);
V = cast(apply_shifts(single(V), shifts, options_nr), orig_class);

% The valid region, from the same warp rather than from the pixel values. The
% probe is a single-precision copy of the chunk, which is why it is built here
% and cleared straight away rather than kept.
probe = apply_shifts(ones(d1, d2, numel(shifts), 'single'), shifts, options_nr);
valid = all(probe >= 1 - 1e-4 & ~isnan(probe), 3);
clear probe
end
