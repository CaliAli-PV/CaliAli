function [Mr,Ref]=Rigid_mc(Y,opt)
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
tic; [~,shifts,~] = normcorre_batch(Ref(b1+1:d1-b1,b2+1:d2-b2,:),options_r); toc 

Ref=v2uint16(Ref); % Convert to uint16.

% Apply shifts to each frame.
parfor i=1:size(Y,3)
    Mr(:,:,i) = imtranslate(Y(:,:,i)+1,flip(squeeze(shifts(i).shifts)'),'FillValues',0); 
    Ref(:,:,i) = imtranslate(Ref(:,:,i)+1,flip(squeeze(shifts(i).shifts)'),'FillValues',0); 
end
end