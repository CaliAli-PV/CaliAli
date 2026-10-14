function tf = postprocess_traces_enabled(neuron)
%% postprocess_traces_enabled: Whether the final traces are post-processed.
%
% Reads cnmf.postprocess_traces from the options saved with the extraction.
% When true, the traces are scaled to noise units (scale_to_noise), detrended
% (detrend_Ca_traces) and, with deconv_flag, deconvolved once more. When false,
% they stay as the CNMF iterations left them, in movie units.
%
% Options saved before the setting existed have no such field: they get true,
% which is what every extraction did then.
%
% Inputs:
%   neuron - Sources2D object with CaliAli_options.
%
% Outputs:
%   tf - true to post-process the final traces.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

tf = true;
try
    tf = logical(neuron.CaliAli_options.cnmf.postprocess_traces);
catch
    % no saved setting: keep the default
end
end
