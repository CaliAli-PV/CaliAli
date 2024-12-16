% Function to post-process deconvolved calcium traces
% 
% This function applies deconvolution to calcium traces and performs post-processing
% to denoise the traces based on specified options.
%
% Inputs:
%   neuron - A struct containing the raw calcium traces (neuron.C_raw)
%   method - (Optional) The deconvolution method to use (default is 'foopsi')
%   type - (Optional) The type of deconvolution (default is 'ar2')
%   smin - (Optional) Minimum threshold for deconvolution (default is -5)
%
% Outputs:
%   neuron - Updated struct with processed calcium traces (neuron.C and neuron.S)

function neuron = postprocessDeconvolvedTraces(neuron, method, type, smin)

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
