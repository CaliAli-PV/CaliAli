function scale_to_noise(neuron)
%% scale_to_noise: Normalizes raw calcium traces based on estimated noise levels.
%
% Inputs:
%   neuron - A `Sources2D` object containing extracted calcium signals and options.
%
% Outputs:
%   The function modifies `neuron.C_raw` in place, normalizing calcium traces using noise estimates.
%
% Usage:
%   scale_to_noise(neuron);
%
% Description:
%   - This function estimates the noise level by computing the residual between the raw calcium trace (`C_raw`)
%     and the deconvolved signal.
%   - A moving window approach is used to handle large datasets.
%   - The noise is estimated using `GetSn`, which calculates the standard deviation of the residual signal.
%   - Finally, the raw calcium traces are normalized by the noise level.
%
% Features:
%   - Automatically handles batch processing if the dataset is split into multiple segments.
%   - Uses detrending to remove slow fluctuations before noise estimation.
%   - Calls `justdeconv` to perform deconvolution with user-specified settings.
%
% Notes:
%   - ⚠ WARNING: Running this function modifies the temporal traces in a way that makes them unsuitable for 
%     further CNMF iterations. If additional CNMF iterations are needed, `update_temporal_CaliAli` must be 
%     rerun to restore a compatible state.
%   - This function improves the signal-to-noise ratio by adjusting traces based on noise levels.
%   - Proper scaling helps in downstream analysis, including neuron classification and activity detection.
%
% Author: Pablo Vergara  
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025


if size(get_batch_size(neuron),2)>1
    c=cumsum(get_batch_size(neuron))';
    c=[[0;c(1:end-1)]+1,c];
else
    c=[neuron.frame_range(1),neuron.frame_range(2)];
end

% Keep the gain that is divided out. The traces have to stay in noise units --
% the deconvolution downstream applies an absolute amplitude threshold -- but a
% residual needs them back in movie units, and without the factor there is no
% way to get there. See trace_noise_scale.
sn_all = ones(size(neuron.C_raw,1), size(c,1));
for i=1:size(c,1)
    temp=neuron.C_raw(:,c(i,1):c(i,2)); % 1) we susbtract the deconvolved signal from the raw calcium trace.
    temp=detrend(temp')';
    sn = GetSn(temp);
    sn = sn(:);
    sn(~isfinite(sn) | sn<=0) = 1;
    sn_all(:,i) = sn;
    temp=temp./sn;
    neuron.C_raw(:,c(i,1):c(i,2))=temp;   % 3) we scale the raw signal. 
end
trace_noise_scale(neuron, 'record', c, sn_all);

justdeconv(neuron,neuron.options.deconv_options.method,neuron.options.deconv_options.type,neuron.options.deconv_options.smin);
