function params=CaliAli_demo_parameters()
%% CaliAli_demo_parameters: Define demo parameters for CaliAli processing pipeline.
%
% This function initializes and returns a structure containing default parameters 
% for data preprocessing, motion correction, inter-session alignment, and neuronal 
% extraction using CNMF-E.
%
% Inputs:
%   None.
%
% Outputs:
%   params - Structure containing all default parameters for CaliAli processing.
%
% Usage:
%   params = CaliAli_demo_parameters();
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% --- Data Preprocessing ---
params.batch_sz = 'auto';        % Maximum frames to load at each time. Auto detect
params.gSig = [];                % Gaussian filter size for neurons (pixels)
params.sf = 10;                  % Frame rate (fps)
params.BVsize = [];              % Size of blood vessels (pixels), 
                                 %  [min diameter, max diameter]. 
                                 %  Default is calculated based on gSig.
params.spatial_ds = 2;           % Spatial downsampling factor
params.temporal_ds = 1;          % Temporal downsampling factor

params.neuron_enhance = true;   % Enhance neurons using MIN1PIE background subtraction
params.noise_scale = true;      % Scale noise for each pixel
params.detrend = 1;             % Detrending window (seconds). 0 = no detrending
params.file_extension = 'avi';  % if a folder is selected instead of a single video file, 
                                % Concatenate all videos with the specified 
                                % file extension within that folder.
params.force_non_negative = 1;               % Enforce non-negative pixels after detrending
params.force_non_negative_tolerance = 20;    % Allow pixel values to go negative up to a tolerance of 20


% --- Motion Correction ---
params.do_non_rigid = false;       % Perform non-rigid motion correction?
params.reference_projection_rigid = 'BV';  % Use blood vessels as reference for rigid correction
params.non_rigid_pyramid = {'BV', 'BV', 'neuron'}; % Multi-level registration pyramid
params.non_rigid_batch_size = [20, 60]; % Frame range for parallel processing



% --- Inter-session Alignment ---
params.projections = 'BV+neuron';     % Use both blood vessels and neurons for alignment
params.final_neurons = false;         % Perform an extra neuron alignment iteration? 
params.Force_BV = false;              % Force BV use even if deemed unusable


% --- Neuronal Extraction (CNMF-E) ---
params.with_dendrites = true;        % Include dendrites in the model
params.search_method = 'dilate';     % Search method ('dilate' or 'ellipse')
params.spatial_constraints = ...     % Spatial constraints
    struct('connected', false, 'circular', false);  
params.spatial_algorithm = 'hals_thresh'; % Spatial extraction algorithm

params.deconv_options = struct(...    % Deconvolution options
    'type', 'ar1', ...               % Calcium trace model ('ar1' or 'ar2')
    'method', 'foopsi', ...          % Deconvolution method
    'smin', -5, ...                  % Minimum spike size
    'optimize_pars', true, ...       % Optimize AR parameters
    'optimize_b', true, ...          % Optimize baseline
    'max_tau', 100);                 % Max decay time (frames)

params.background_model = 'ring';    % Background model
params.nb = 1;                       % Number of background components
params.bg_neuron_factor = 1.5;       % 
params.ring_radius = [];             % Will be calculated later
params.num_neighbors = [];           % Number of neighbors for each neuron
params.bg_ssub = 2;                  % Background downsampling factor

params.merge_thr = 0.65;             % Merging threshold
params.method_dist = 'max';          % Distance calculation method
params.dmin = 5;                     % Minimum distance between neurons
params.merge_thr_spatial = ...       % Spatial merging threshold
    [0.8, 0.4, -inf];                 

params.min_corr = 0.2;               % Minimum correlation for seeding
params.min_pnr = 4;                  % Minimum peak-to-noise ratio for seeding


params=CaliAli_parameters(params);