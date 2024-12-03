function params=CaliAli_demo_parameters()
% CaliAli_parameters  Defines parameters for CaliAli.

% --- Data Preprocessing ---
params.gSig = 2.5;              % Gaussian filter size for neurons (pixels)
params.sf = 10;                 % Frame rate (fps)
params.BVsize = [];             % Size of blood vessels (pixels), 
                                 %  [min diameter, max diameter]. 
                                 %  Default is calculated based on gSig.
params.spatial_ds = 2;          % Spatial downsampling factor
params.temporal_ds = 2;         % Temporal downsampling factor

params.neuron_enhance = true;   % Enhance neurons using MIN1PIE background subtraction
params.noise_scale = true;      % Scale noise for each pixel
params.detrend = 1;             % Detrending window (seconds). 0 = no detrending


% --- Motion Correction ---
params.do_non_rigid = false;       % Perform non-rigid motion correction?
params.reference_projection_rigid = 'BV';  % Use blood vessels as reference for rigid correction
params.non_rigid_pyramid = {'BV', 'BV', 'neuron'}; % Multi-level registration pyramid
params.non_rigid_batch_size = [20, 60]; % Frame range for parallel processing


% --- Inter-session Alignment ---
params.projections = 'BV+neuron';     % Use both blood vessels and neurons for alignment
params.final_neurons = 0;              % Perform an extra neuron alignment iteration? 
params.Force_BV = false;              % Force BV use even if deemed unusable


% --- Neuronal Extraction (CNMF-E) ---
params.frames_per_batch = 0;          % Number of frames per batch. 0 = process each session as a single batch
params.memory_size_to_use = 256;      % Memory allowed for MATLAB (GB)
params.memory_size_per_patch = 16;    % Memory for each patch (GB)
params.patch_dims = [64, 64];         % Patch dimensions

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

params.min_corr = 0.1;               % Minimum correlation for seeding
params.min_pnr = 6;                  % Minimum peak-to-noise ratio for seeding
