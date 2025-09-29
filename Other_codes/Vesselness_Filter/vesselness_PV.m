function vid=vesselness_PV(vid,use_parallel,sz,norm)
%% vesselness_PV: Apply vesselness filtering to enhance blood vessels in an image or video.
%
% This function enhances blood vessels in an input image or video using 
% vesselness filtering. It supports both sequential and parallel processing.
%
% Inputs:
%   vid         - Input image or video as a 2D or 3D array.
%   use_parallel - (Optional) Boolean flag to enable parallel processing (default: 1).
%   sz          - (Optional) Scale range for the vesselness filter (default: 0.5:0.5:2).
%   norm        - (Optional) Normalization flag for vesselness filtering (default: 0).
%
% Outputs:
%   vid - Image or video with enhanced blood vessels.
%
% Usage:
%   vid_filtered = vesselness_PV(vid);  % Default parameters with parallel processing
%   vid_filtered = vesselness_PV(vid, 0, 0.5:0.5:2, 1);  % Sequential processing with normalization
%
% Notes:
%   - Uses vesselness filtering to enhance tubular structures in images.
%   - Parallel processing is available for large videos to improve efficiency.
%   - Normalization ensures that vessel structures are highlighted consistently.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

if ~exist('sz','var')
    sz=0.5:0.5:2;
end
if ~exist('norm','var')
    norm=0;
end

if ~exist('use_parallel','var')
    use_parallel=1;
end

if use_parallel
    vid = videoConvert(vid);
    parfor i=1:size(vid,2)
        temp=double(vid{i});
        temp=apply_vesselness_filter(temp,sz,norm);
        vid{i}=temp;
    end
    vid = videoConvert(vid);
else
    for i=1:size(vid,3)
        temp=double(vid(:,:,i));
        temp=apply_vesselness_filter(temp,sz,norm);
        vid(:,:,i)=temp;
    end
end
end

function out=apply_vesselness_filter(in,sz,norm)
% in= medfilt2(in);
Ip=mat2gray(in);
% Ip = single(in);
% thr = prctile(Ip(Ip(:)>0),1) * 0.9;
% Ip(Ip<=thr) = thr;
% Ip = Ip - min(Ip(:));
% Ip = Ip ./ max(Ip(:));    
% 
% % compute enhancement for two different tau values
 out = vesselness2D(Ip, sz, [1;1], 0.8, false,norm);
% out = vesselness2D(Ip, 0.05:0.05:1.5, [1;1], 1, false);
end
