function [Mr,Ref,template,valid]=Rigid_mc(Y,opt,template)
%% Rigid_mc: Perform rigid motion correction using NoRMCorre.
%
% This function applies rigid motion correction to a 3D image volume using
% the NoRMCorre algorithm. The correction is based on a reference projection
% that can be computed using blood vessel extraction or background removal.
%
% Inputs:
%   Y   - 3D image volume to be motion corrected.
%   opt - Structure containing motion correction options.
%
% Outputs:
%   Mr  - Motion-corrected 3D image volume.
%   Ref - Reference projection used for motion correction.
%
% Usage:
%   [Mr, Ref] = Rigid_mc(Y, opt);
%
% Author: Written by Pablo Vergara utilizing the codes of Eftychios A. Pnevmatikakis
%            Simons Foundation, 2016
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

fprintf('Appling translation motion correction...\n');
% Generate reference projection based on specified option.
if strcmp(opt.reference_projection_rigid,'BV')
    Ref=CaliAli_get_blood_vessels(Y,opt); % Correct for vignetting.
elseif strcmp(opt.reference_projection_rigid,'neuron')
    Ref=CaliAli_remove_background(Y,opt); % Remove background.
end

[d1,d2,~] = size(Ref);
b1=round(d1/10); % Border size for cropping.
b2=round(d2/10);

% Determine binning size for NoRMCorre.
if size(Y,3)<200
    binz=size(Y,3);
else
    binz=200;
end

% Set NoRMCorre parameters.
%
% PIECEWISE-RIGID INSTEAD OF A SEPARATE NON-RIGID MODULE. NoRMCorre corrects
% non-rigid motion by giving each patch of the frame its own rigid shift, bounded
% so it cannot stray far from the whole-frame one. Leaving grid_size at the frame
% size gives exactly one patch, which is plain rigid correction -- so the two
% cases are the same call with a different grid, not two separate algorithms.
%
% This replaces Non_rigid_mc, which registered with a KLT tracker and needed
% detectMinEigenFeatures and vision.PointTracker from the Computer Vision
% Toolbox. Without that toolbox every call threw, a bare catch turned each into
% NaN, and the failure surfaced much later as interp1 complaining about sample
% points -- a message with nothing to do with the cause. NoRMCorre needs no
% toolbox beyond Image Processing, which the rest of the pipeline already
% requires.
if opt.do_non_rigid
    % NO BORDER TRIM HERE, and that is not an oversight. A piecewise shift is a
    % field laid out on a grid of patches, and the grid it is ESTIMATED on has to
    % be the grid it is APPLIED on -- estimate on a trimmed frame and apply to
    % the full one and the patches do not correspond, which is exactly what
    % mat2cell complains about. The trim exists to keep a whole-frame phase
    % correlation off the frame edge; in patch mode max_dev already bounds how
    % far any patch, edge ones included, may depart from the whole-frame shift,
    % so the protection it gave is still there.
    scale = 16;
    if isfield(opt,'non_rigid_patch_scale') && ~isempty(opt.non_rigid_patch_scale)
        scale = opt.non_rigid_patch_scale;
    end
    [grid_size, mot_uf, max_dev] = non_rigid_grid_default([d1, d2], opt.gSig, scale);
    options_r = NoRMCorreSetParms('d1',d1,'d2',d2,'bin_width',binz, ...
        'max_shift',20,'iter',1,'correct_bidir',false, ...
        'grid_size',grid_size,'mot_uf',mot_uf,'max_dev',max_dev, ...
        'shifts_method','fft','boundary','nan');
    reg_in = Ref;
    fprintf('Non-rigid: %dx%d patches over a %dx%d frame.\n', ...
        ceil(d1/grid_size(1)), ceil(d2/grid_size(2)), d1, d2);
else
    options_r = NoRMCorreSetParms('d1',d1-b1*2,'d2',d2-b2*2,'bin_width',binz,'max_shift',20,'iter',1,'correct_bidir',false);
    reg_in = Ref(b1+1:d1-b1, b2+1:d2-b2, :);
end

% Perform motion correction on cropped reference.
if exist('template','var')
    tic; [~,shifts,template] = normcorre_batch(reg_in,options_r,template); toc
else
    tic; [~,shifts,template] = normcorre_batch(reg_in,options_r); toc
end
clear reg_in

Ref=v2uint16(Ref); % Convert to uint16.

% Apply shifts to each frame.
%
% WHERE THE VALID REGION COMES FROM. Translating leaves empty pixels at the
% borders. Those have to be told apart from real data, and this used to be done
% by adding 1 to the whole recording first, so that 0 could only mean "filled".
% That offset travelled through the entire pipeline -- nothing ever subtracted it
% -- and square_borders, apply_mask_square and the dropped-frame test all came to
% depend on the value 0 carrying that meaning. It was removed, but the reasoning
% behind it stayed: the border was still being found by looking at pixel VALUES,
% and after that removal a genuine 0 is indistinguishable from a filled one.
%
% The shift is known, so the valid region does not have to be guessed from the
% data at all. The SAME translation is applied to a mask of true, and what comes
% back is exactly which pixels are real. It is logical, so imtranslate resamples
% it nearest-neighbour, which matches how the data itself is treated: a pixel
% interpolated partly from real data counts as real in both.
if opt.do_non_rigid
    % A piecewise shift is a field, not a pair of numbers, so it is applied with
    % apply_shifts rather than imtranslate. The valid region comes from the same
    % call on a frame of ones: whatever it does to the data it does to the mask.
    % options_r describes the same grid the shifts were estimated on, so it is
    % passed through unchanged -- no dimension of it may be edited here.
    Mr  = cast(apply_shifts(single(Y), shifts, options_r), 'like', Y);
    Ref = cast(apply_shifts(single(Ref), shifts, options_r), 'like', Ref);
    probe = apply_shifts(ones(size(Y), 'single'), shifts, options_r);
    valid = all(probe >= 1 - 1e-4 & ~isnan(probe), 3);
    clear probe
else
    Mr = zeros(size(Y), 'like', Y);
    valid = true(size(Y,1), size(Y,2));
    parfor i=1:size(Y,3)
        shift_i = flip(squeeze(shifts(i).shifts)');
        Mr(:,:,i) = imtranslate(Y(:,:,i), shift_i, 'FillValues', 0);
        valid = valid & imtranslate(true(size(Y,1),size(Y,2)), shift_i, 'FillValues', 0);
        Ref(:,:,i) = imtranslate(Ref(:,:,i), shift_i, 'FillValues', 0);
    end
end
% VALID is already the intersection over every frame: a pixel is usable only if
% it is present in all of them.
end