function Y=detrend_vid(Y,CaliAli_options)
%% detrend_vid: Remove slow fluctuations in brightness from video data.
%
% This function performs detrending on a video by applying a moving median 
% filter followed by a moving minimum filter. It helps to correct slow 
% fluctuations in intensity over time.
%
% Inputs:
%   Y               - Input video as a 3D array (height x width x frames).
%   CaliAli_options - Structure containing preprocessing parameters.
%                     The details of this structure can be found in 
%                     CaliAli_demo_parameters().
%
% Outputs:
%   Y - Detrended video with slow fluctuations removed.
%
% Usage:
%   Y_detrended = detrend_vid(Y, CaliAli_options);
%
% Notes:
%   - The moving median filter operates over a window size determined by the 
%     product of the sampling frequency and the detrending factor.
%   - A secondary moving minimum filter is applied to further refine background 
%     fluctuations.
%   - Negative values are clipped to zero after detrending.
%
% Author: Pablo Vergara

[d1,d2,d3]=size(Y);
obj=reshape(single(Y),d1*d2,d3);
temp=movmedian(obj,CaliAli_options.preprocessing.sf*CaliAli_options.preprocessing.detrend,2);
temp=movmin(temp,CaliAli_options.preprocessing.sf*CaliAli_options.preprocessing.detrend*5,2);
Y=double(obj-temp);
Y=gather(reshape(Y,d1,d2,d3));
end
