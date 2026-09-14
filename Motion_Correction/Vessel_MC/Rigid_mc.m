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
options_r = NoRMCorreSetParms('d1',d1-b1*2,'d2',d2-b2*2,'bin_width',binz,'max_shift',20,'iter',1,'correct_bidir',false);

% Perform motion correction on cropped reference.
if exist('template','var')
    tic; [~,shifts,template] = normcorre_batch(Ref(b1+1:d1-b1,b2+1:d2-b2,:),options_r,template); toc
else
    tic; [~,shifts,template] = normcorre_batch(Ref(b1+1:d1-b1,b2+1:d2-b2,:),options_r); toc
end

Ref=v2uint16(Ref); % Convert to uint16.

% Apply shifts to each frame.
%
% THE +1 AND WHY IT IS UNDONE. Translating leaves empty pixels at the borders,
% filled with 0. Those have to be told apart from real data, and the way that
% was done was to add 1 to the whole recording first, so that 0 could only mean
% "filled". That offset then travelled through the entire pipeline: nothing ever
% subtracted it, and square_borders, apply_mask_square and the dropped-frame
% test all came to depend on the value 0 carrying that meaning.
%
% The offset is still used to find the borders -- it is the cheapest way -- but
% it is removed again on the same line, and the region it identified is returned
% as VALID, a logical mask. Callers get the true pixel values and an explicit
% mask, instead of shifted values and a convention.
Mr = zeros(size(Y), 'like', Y);
valid = false(size(Y));
parfor i=1:size(Y,3)
    shift_i = flip(squeeze(shifts(i).shifts)');
    frame = imtranslate(Y(:,:,i)+1, shift_i, 'FillValues', 0);
    valid(:,:,i) = frame > 0;              % 0 here can only be a filled pixel
    frame(frame > 0) = frame(frame > 0) - 1;   % put the real values back
    Mr(:,:,i) = frame;
    Ref(:,:,i) = imtranslate(Ref(:,:,i), shift_i, 'FillValues', 0);
end
valid = all(valid, 3);   % a pixel is usable only if it is present in EVERY frame
end