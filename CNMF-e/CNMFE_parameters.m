function pars=CNMFE_parameters(varargin)
%% CNMFE_parameters: Define and configure parameters for CNMF-E processing.
%
% This function initializes and returns a structured set of parameters for 
% constrained non-negative matrix factorization (CNMF-E), including spatial, 
% temporal, background, and merging constraints for neuronal extraction.
%
% Inputs:
%   varargin - Variable input arguments, which can be an existing structure 
%              or key-value pairs specifying parameters.
%
% Outputs:
%   pars - Structure containing all CNMF-E processing parameters.
%
% Usage:
%   pars = CNMFE_parameters();  % Default parameter initialization
%   pars = CNMFE_parameters(existing_pars);  % Use existing parameter structure
%
% Notes:
%   - This function includes parameters for spatial filtering, deconvolution, 
%     background modeling, merging constraints, initialization settings, and 
%     dendrite processing (in progress).
%   - Dependent parameters such as Gaussian filter size and background radius 
%     are computed based on other user-defined values.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025
%% INTIALIZE VARIABLES
inp = inputParser;
inp.PartialMatching = false;
inp.KeepUnmatched = true; % Keep unmatched parameters

%% General variables
% -------------------------    COMPUTATION    -------------------------  %
addParameter(inp, 'pars_envs', pars_envs_parse(varargin{:}), @isstruct);  % Patch dimensions

% -------------------------      SPATIAL      -------------------------  %
addParameter(inp, 'gSig', [], @isnumeric);          % pixel, gaussian width of a gaussian kernel for filtering the data. usually 1/3 of neuron diameter
addParameter(inp, 'gSiz', [], @isnumeric);          % This will be calculated later
addParameter(inp, 'ssub', 1, @isnumeric);           % spatial downsampling factor
addParameter(inp, 'with_dendrites', true, @islogical);   % with dendrites or not
addParameter(inp, 'search_method', 'dilate', @ischar);  % method to determine search locations ('dilate','ellipse' or 'grow (for dendrites)')
addParameter(inp, 'bSiz', 5, @isnumeric);
addParameter(inp, 'dist', [], @isnumeric);           % This will be set conditionally later
addParameter(inp, 'spatial_constraints', struct('connected', false, 'circular', false), @isstruct);  % you can include following constraints: 'circular'
addParameter(inp, 'spatial_algorithm', 'hals_thresh', @ischar);

% -------------------------      TEMPORAL     -------------------------  %
addParameter(inp, 'sf', [], @isnumeric);             % frame rate
addParameter(inp, 'tsub', 1, @isnumeric);           % temporal downsampling factor
addParameter(inp, 'deconv_flag', true, @islogical);     % run deconvolution or not
addParameter(inp, 'deconv_options', struct('type', 'ar1', ... % model of the calcium traces. {'ar1', 'ar2'}
    'method', 'foopsi', ... % method for running deconvolution {'foopsi', 'constrained', 'thresholded'}
    'smin', -5, ...         % minimum spike size. When the value is negative, the actual threshold is abs(smin)*noise level
    'optimize_pars', true, ...  % optimize AR coefficients
    'optimize_b', true, ...% optimize the baseline);
    'max_tau', 100), @isstruct);    % maximum decay time (unit: frame);
addParameter(inp, 'nk', 1, @isnumeric);             % detrending the slow fluctuation. usually 1 is fine (no detrending)
addParameter(inp, 'detrend_method', 'spline');  % compute the local minimum as an estimation of trend.

% -------------------------     BACKGROUND    -------------------------  %
addParameter(inp, 'background_model', 'ring', @ischar);  % model of the background {'ring', 'svd'(default), 'nmf'}
addParameter(inp, 'nb', 1, @isnumeric);             % number of background sources for each patch (only be used in SVD and NMF model)
addParameter(inp, 'bg_neuron_factor', 1.5, @isnumeric);
addParameter(inp, 'ring_radius', [], @isnumeric);     % This will be calculated later
addParameter(inp, 'num_neighbors', [], @isnumeric); % number of neighbors for each neuron
addParameter(inp, 'bg_ssub', 2, @isnumeric);        % downsample background for a faster speed

% -------------------------      MERGING      -------------------------  %
addParameter(inp, 'merge_thr', 0.65, @isnumeric);     % thresholds for merging neurons; [spatial overlap ratio, temporal correlation of calcium traces, spike correlation]
addParameter(inp, 'method_dist', 'max', @ischar);   % method for computing neuron distances {'mean', 'max'}
addParameter(inp, 'dmin', 5, @isnumeric);       % minimum distances between two neurons. it is used together with merge_thr
addParameter(inp, 'merge_thr_spatial', [0.8, 0.4, -inf], @isnumeric);  % merge components with highly correlated spatial shapes (corr=0.8) and small temporal correlations (corr=0.1)
addParameter(inp, 'merge_thr_fiber', [30, 5,15,0.4], @isnumeric);  % merge close fiber with similar orientation. [distance, paralle distance,angle, temporal correlation].

% -------------------------  INITIALIZATION   -------------------------  %
addParameter(inp, 'K', [], @isnumeric);             % maximum number of neurons per patch. when K=[], take as many as possible.
addParameter(inp, 'min_corr', 0.1, @isnumeric);     % minimum local correlation for a seeding pixel (Corr_th)
addParameter(inp, 'min_pnr', 6, @isnumeric);       % minimum peak-to-noise ratio for a seeding pixel (PNR_th)
addParameter(inp, 'min_pixel', [], @isnumeric);      % This will be calculated later
addParameter(inp, 'bd', 0, @isnumeric);             % number of rows/columns to be ignored in the boundary (mainly for motion corrected data)
addParameter(inp, 'use_parallel', true, @islogical);    % use parallel computation for parallel computing
addParameter(inp, 'center_psf', true, @islogical);  % set the value as true when the background fluctuation is large (usually 1p data)
addParameter(inp, 'seed_mask', []);  % Used internally

%% Parse Inputs
varargin=varargin{:};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end
parse(inp, varargin{:});
pars = inp.Results;



%% Calculate Dependent Parameters
pars.gSiz = min(pars.gSig) * 4;
pars.ring_radius = round(pars.bg_neuron_factor * min(pars.gSiz));

if isempty(pars.min_pixel)
    if length(pars.gSig)>1
        pars.min_pixel = prod(pars.gSig);
    else
        pars.min_pixel = pars.gSig^2;
    end
end


%% Conditional Parameter Setting
if pars.with_dendrites
    pars.bSiz = 5;
else
    pars.dist = 5;
end
end


function pars=pars_envs_parse(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
inp.PartialMatching = false;
inp.KeepUnmatched = true;  % Keep unmatched parameters

try
[total_system_memory_GB,~] = getSystemMemory;
catch
fprintf('Total physical memory could not be determined.\n');
fprintf('Avilable memory was set to 120GB by default.\n');
total_system_memory_GB=120;
fprintf('Manually set available RAM with CaliAli_parameters(''memory_size_to_use'', val); to define different value\n');
end



addParameter(inp,'memory_size_to_use', total_system_memory_GB, @isnumeric);  % GB, memory space you allow to use in MATLAB
addParameter(inp,'memory_size_per_patch',total_system_memory_GB, @isnumeric);                    % GB, space for loading data within one patch
addParameter(inp,'patch_dims', [64, 64], @isnumeric);                        % Patch dimensions
addParameter(inp,'w_overlap', 32, @isnumeric); 


varargin=varargin{:};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end
parse(inp, varargin{:});
pars = inp.Results;
end



