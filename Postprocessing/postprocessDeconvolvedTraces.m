function neuron = postprocessDeconvolvedTraces(neuron, method, type, smin)

%% postprocessDeconvolvedTraces: Refines deconvolved calcium traces after CNMF iterations.
%
% Inputs:
%   neuron - A struct containing the raw calcium traces (neuron.C_raw).
%   method - (Optional) The deconvolution method to use (default is 'foopsi').
%   type   - (Optional) The type of deconvolution (default is 'ar2').
%   smin   - (Optional) Minimum threshold for deconvolution (default is -5).
%
% Outputs:
%   neuron - Updated struct with processed calcium traces (neuron.C and neuron.S).
%
% Usage:
%   neuron = postprocessDeconvolvedTraces(neuron);
%   neuron = postprocessDeconvolvedTraces(neuron, 'thresholded', 'ar1', -3);
%
% Description:
%   - This function applies deconvolution to calcium traces and performs post-processing
%     to denoise the traces based on specified options.
%   - It allows users to change the autoregressive model (`ar1`, `ar2`, etc.) at the end 
%     of CNMF iterations for refined neuronal activity estimation.
%   - This is particularly useful if a fast deconvolution method (e.g., `foopsi`) was used 
%     during CNMF iterations, and a more precise but slower thresholded method is desired 
%     for final processing.
%
% Features:
%   - Supports multiple deconvolution methods (Foopsi, constrained Foopsi, thresholded).
%   - Allows for fine-tuning spike detection sensitivity with `smin`.
%   - Improves signal quality by denoising traces with adaptive thresholding.
%   - Parallelized execution for faster processing of large datasets.

%
% Author: Pablo Vergara  
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025

    % Default values for optional parameters
    if ~exist('method', 'var')
        method = 'foopsi';
    end

    if ~exist('type', 'var')
        type = 'ar2';
    end

    if ~exist('smin', 'var')
        smin = -5;
    end

    % Set deconvolution options
    deconv_options.method = method;
    deconv_options.optimize_pars = 1;
    deconv_options.type = type;
    deconv_options.smin = smin;

    % Perform deconvolution
    neuron = deconv_traces(neuron, deconv_options);
end

% Function to perform deconvolution on calcium traces
% 
% This function applies deconvolution to each trace in the input neuron struct
% and performs denoising based on the specified options.
%
% Inputs:
%   neuron - A struct containing the raw calcium traces (neuron.C_raw)
%   deconv_options - Struct with deconvolution options
%
% Outputs:
%   neuron - Updated struct with deconvolved and denoised traces (neuron.C and neuron.S)

function neuron = deconv_traces(neuron, deconv_options)

    % Extract raw calcium traces
    cr = neuron.C_raw;
    c = [];
    s = [];

    b = ProgressBar(size(cr, 1), ...
        'IsParallel', true, ...
        'WorkerDirectory', pwd(), ...
        'Title', 'Deconvolving' ...
        );

    % ALWAYS CALL THE SETUP() METHOD FIRST!!!
    b.setup([], [], []);
    % Perform deconvolution for each trace using parallel processing
    parfor i = 1:size(cr, 1)
        [c(i,:), s(i,:), ~] = deconvolveCa(cr(i,:), deconv_options, 'sn', 1);
        updateParallel([], pwd);
    end
    b.release();
    % Denoise the deconvolved traces
    [c, s] = denoise_traces(cr, c, s, abs(deconv_options.smin), neuron.sf);
    
    % Update neuron struct with deconvolved and denoised traces
    neuron.C = c;
    neuron.S = s;
end

% Function to denoise calcium traces
% 
% This function applies denoising to the deconvolved traces based on thresholding
% and moving window operations.
%
% Inputs:
%   cr - Raw calcium traces
%   c - Deconvolved calcium traces
%   s - Deconvolved spike traces
%   thr_v - Threshold value for denoising
%   sf - Sampling frequency
%
% Outputs:
%   c - Denoised deconvolved calcium traces
%   s - Denoised deconvolved spike traces

function [c, s] = denoise_traces(cr, c, s, thr_v, sf)

    % Apply a moving median filter to the raw traces
    t = movmedian(cr, 5, 2);
    
    % Set threshold based on input or moving minimum
    if thr_v == 0
        thr = abs(movmin(t, 60 * sf, 2)) * 2;
    else
        thr = ones(1, size(c, 2)) * thr_v;
    end
    
    % Apply moving maximum filter
    a = movmax(t, 10 * sf, 2);
    
    % Thresholding to remove noise
    c(a < thr) = 0;
    s(a < thr) = 0;

    % Ensure that negative values are removed
    s(min(c, [], 2) < 0, :) = 0;
    c(min(c, [], 2) < 0, :) = 0;
end
