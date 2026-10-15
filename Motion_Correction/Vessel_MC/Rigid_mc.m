function [Mr,Ref,template,valid]=Rigid_mc(Y,opt,template)
%% Rigid_mc: Perform rigid motion correction using NoRMCorre.
%
% This function applies rigid motion correction to a 3D image volume using
% the NoRMCorre algorithm. The correction is based on a reference projection
% that can be computed using blood vessel extraction or background removal.
%
% Inputs:
%   Y        - 3D image volume to be motion corrected.
%   opt      - Structure containing motion correction options.
%   template - (Optional) Template returned by a previous call, to register
%              later chunks of the same session to the same image.
%
% Outputs:
%   Mr       - Motion-corrected 3D image volume.
%   Ref      - Reference projection used for motion correction.
%   template - Template the frames were registered to.
%   valid    - Logical mask, true where every frame holds real data after shifting.
%
% Usage:
%   [Mr, Ref, template, valid] = Rigid_mc(Y, opt);
%   [Mr, Ref, template, valid] = Rigid_mc(Y, opt, template);
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
else
    error('CaliAli:InvalidReferenceProjection', ...
        'reference_projection_rigid must be ''BV'' or ''neuron'', not ''%s''.', ...
        char(string(opt.reference_projection_rigid)));
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
% TWO PASSES. Cross-correlation of the vessel map, which is smooth, has a broad
% peak that is precise for small shifts and unreliable for large ones: on a
% simulated session shaken up to 15 px, 58 of 2000 frames came out wrong by
% more than a pixel (1.72 px of motion left). Phase correlation whitens the
% spectrum and finds those shifts (1 frame wrong, 0.33 px left), but alone it is
% less precise on ordinary sessions (0.166 px left against 0.148). So phase
% correlation finds the shift, and cross-correlation refines it within 3 px:
% 0.30 px left on the shaken session, 0.134 on an ordinary one.
%
% AND CROSS-CORRELATION ALONE, FRAME BY FRAME. Phase correlation weights every
% frequency equally, and on a deformed frame the fine ones no longer match: on a
% simulated recording with a 6 px deformation it put 26 of 1500 frames more
% than 5 px off (the worst 33 px), where cross-correlation alone put none, and
% the refinement within 3 px cannot bring such a frame back. So cross-
% correlation alone is run as well, and where the two disagree by more than a
% pixel the frame takes whichever shift makes it match the template better.
options_r = NoRMCorreSetParms('d1',d1-b1*2,'d2',d2-b2*2,'bin_width',binz,'max_shift',20,'iter',1,'correct_bidir',false,'phase_flag',true);
options_f = NoRMCorreSetParms('d1',d1-b1*2,'d2',d2-b2*2,'bin_width',binz,'max_shift',3,'iter',1,'correct_bidir',false,'phase_flag',false);
options_x = NoRMCorreSetParms('d1',d1-b1*2,'d2',d2-b2*2,'bin_width',binz,'max_shift',20,'iter',1,'correct_bidir',false,'phase_flag',false);

% Perform motion correction on cropped reference.
% NoRMCorre picks the frames for its first template at random from MATLAB's
% global stream (randperm in normcorre_batch), so the correction depended on
% whatever had drawn random numbers earlier in the session: the same file came
% out cropped to a different size from one run to the next. A fixed seed makes
% it repeatable, and the caller's random state is put back afterwards.
prev_rng = rng(0, 'twister');
restore_rng = onCleanup(@() rng(prev_rng)); %#ok<NASGU>
Rc = Ref(b1+1:d1-b1,b2+1:d2-b2,:);
if exist('template','var')
    tic; [R1,shifts,template_p] = normcorre_batch(Rc,options_r,template); toc
    tic; [~,cross] = normcorre_batch(Rc,options_x,template); toc
else
    tic; [R1,shifts,template_p] = normcorre_batch(Rc,options_r); toc
    rng(0, 'twister');
    tic; [~,cross] = normcorre_batch(Rc,options_x); toc
end
tic; [~,fine,template] = normcorre_batch(R1,options_f,template_p); toc
for i = 1:numel(shifts)
    shifts(i).shifts = shifts(i).shifts + fine(i).shifts;
end
clear R1 fine template_p
[shifts, n_apart, n_cross] = keep_better_shift(Rc, shifts, cross, template);
if n_apart > 0
    fprintf('%d of %d frames: phase and cross-correlation disagreed by more than 1 px; %d took the cross-correlation shift.\n', ...
        n_apart, numel(shifts), n_cross);
end
clear Rc cross

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
% data at all. The SAME translation, with the same linear interpolation, is
% applied to a frame of ones, and only pixels that come back whole are real.
% This used to translate a LOGICAL mask, which imtranslate resamples
% nearest-neighbour: a pixel that was 40% fill came back as valid while its data
% was 60% of its value. The crop then kept an edge ring whose brightness
% flickered with the motion, and that ring alone cost extraction 0.05 to 0.11
% F1 on a simulated recording (removing it took F1 from 0.714 to 0.763, and
% from 0.547 to 0.656 with a 3 px deformation).
Mr = zeros(size(Y), 'like', Y);
valid = true(size(Y,1), size(Y,2));
parfor i=1:size(Y,3)
    shift_i = flip(squeeze(shifts(i).shifts)');
    Mr(:,:,i) = imtranslate(Y(:,:,i), shift_i, 'FillValues', 0);
    valid = valid & imtranslate(ones(size(Y,1),size(Y,2),'single'), shift_i, 'FillValues', 0) >= 1 - 1e-4;
    Ref(:,:,i) = imtranslate(Ref(:,:,i), shift_i, 'FillValues', 0);
end
% VALID is already the intersection over every frame: a pixel is usable only if
% it is present in all of them.
end


function [shifts, n_apart, n_cross] = keep_better_shift(R, shifts, cross, template)
%% Per frame, the phase-then-refine shift or the cross-correlation one.
% Frames whose two shifts are within a pixel keep the phase-then-refine shift.
% The others are translated by each and compared with the template, inside the
% border that neither translation reaches, and keep the shift that matches better.
n_apart = 0;
n_cross = 0;
template = double(template);
[h, w, ~] = size(R);
for i = 1:numel(shifts)
    p = squeeze(shifts(i).shifts)';
    x = squeeze(cross(i).shifts)';
    if norm(p - x) <= 1
        continue
    end
    n_apart = n_apart + 1;
    m = min(ceil(max(abs([p x]))) + 1, floor((min(h, w) - 2)/2));
    f = double(R(:,:,i));
    if template_match(imtranslate(f, flip(x), 'FillValues', 0), template, m) > ...
            template_match(imtranslate(f, flip(p), 'FillValues', 0), template, m)
        shifts(i).shifts = cross(i).shifts;
        n_cross = n_cross + 1;
    end
end
end


function c = template_match(a, b, m)
%% Correlation of two frames, leaving out m pixels at every edge.
c = corr2(a(m+1:end-m, m+1:end-m), b(m+1:end-m, m+1:end-m));
end