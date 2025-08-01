function M=CaliAli_get_blood_vessels(M,opt)
%% CaliAli_get_blood_vessels: Enhance blood vessels in an image or video.
%
% This function enhances the visibility of blood vessels in an input image 
% or video using a combination of vignetting removal, vesselness filtering, 
% and median filtering.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Set default parameters if 'opt' is not provided
if ~exist('opt','var')
    opt.BVsize=[0.6*2.5,0.9*2.5];  % Default vessel scale range
end
disp('Calculating blood vessels...')
M = remove_vignetting_video_adaptive_batches(M);
if size(M,3)>1
M = mat2gray(vesselness_PV(M,1,linspace(opt.BVsize(1),opt.BVsize(2),10),2));
else
M = mat2gray(vesselness_PV(M,0,linspace(opt.BVsize(1),opt.BVsize(2),10),2));
M = medfilt2(M,'symmetric');  % Apply median filtering
end
M=v2uint8(M);
end


