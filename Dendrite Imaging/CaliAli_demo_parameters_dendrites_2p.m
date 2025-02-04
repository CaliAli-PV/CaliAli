function params=CaliAli_demo_parameters_dendrites_2p()
% CaliAli_parameters  Defines parameters for CaliAli.

% --- Data Preprocessing ---
params.gSig = [3,50];             % Gaussian filter size for dendrite (pixels)
params.sf = 100;                 % Frame rate (fps)
params.BVsize = [0.5,1.5];             % Size of blood vessels (pixels), 
                                 %  [min diameter, max diameter]. 
                                 %  Default is calculated based on gSig.
params.spatial_ds = 1;           % Spatial downsampling factor
params.temporal_ds = 1;          % Temporal downsampling factor

params.neuron_enhance = false;    % Enhance neurons using MIN1PIE background subtraction
params.noise_scale = false;      % Scale noise for each pixel
params.detrend = 2;              % Detrending window (seconds). 0 = no detrending
params.file_extension = 'tif';  % if a folder is selected instead of a single video file, 
% 2p parameters:
params.background_model='svd';


% Dendrite parameters
params.structure='dendrite';
params.dendrite_filter_size=1.5:0.2:3;
params.dendrite_theta=30;        % 0 is 90 degree, 10 is 85 to 95, 20 is 80 to 100
params.fastPNR=false;
params.do_alignment=false;
params.remove_BV=false;
params.median_filtering=[3,1];  %Apply median filtering. Leave empty for no filtering. We use 7x1 to filter vertical elongated structures
params.min_dendrite_size = 50;  % Shortest dendrite length in pixels
params.dendrite_initialization_threshold = 0.01;


% --- Motion Correction ---
params.do_non_rigid = false;       % Perform non-rigid motion correction?
params.reference_projection_rigid = 'neuron';  % Use blood vessels as reference for rigid correction
params.non_rigid_pyramid = {'neuron', 'neuron', 'neuron'}; % Multi-level registration pyramid
params.non_rigid_batch_size = [20, 60]; % Frame range for parallel processing


% --- Inter-session Alignment ---
params.projections = 'neuron';     % Use both blood vessels and neurons for alignment
params.final_neurons = 0;              % Perform an extra neuron alignment iteration? 
params.Force_BV = false;              % Force BV use even if deemed unusable



% --- Neuronal Extraction (CNMF-E) ---
params.batch_sz = 3000;
params.frames_per_batch = 0;          % Number of frames per batch. 0 = process each session as a single batch
params.memory_size_per_patch = 16;    % Memory for each patch (GB)
params.patch_dims = [800, 100];         % Patch dimensions
params.w_overlap = 50;

params.min_pixel=20;
params.with_dendrites = true;        % Include dendrites in the model
params.search_method = 'grow';     % Search method ('dilate' or 'ellipse')
params.spatial_constraints = ...     % Spatial constraints
    struct('connected', true, 'circular', false);  
params.spatial_algorithm = 'hals'; % Spatial extraction algorithm

params.deconv_options = struct(...    % Deconvolution options
    'type', 'ar1', ...               % Calcium trace model ('ar1' or 'ar2')
    'method', 'foopsi', ...          % Deconvolution method
    'smin',-3, ...                   % Minimum spike size
    'optimize_pars', true, ...       % Optimize AR parameters
    'optimize_b', true, ...          % Optimize baseline
    'max_tau', 100);                 % Max decay time (frames)

params.background_model = 'svd';    % Background model
params.nb = 1;                       % Number of background components
params.bg_neuron_factor = 3;       % 
params.ring_radius = [];             % Will be calculated later
params.num_neighbors = [];           % Number of neighbors for each neuron
params.bg_ssub = 2;                  % Background downsampling factor

params.merge_thr = 0.65;             % Merging threshold
params.method_dist = 'max';          % Distance calculation method
params.dmin = 5;                     % Minimum distance between neurons

params.merge_thr_spatial = ...       
                  [0.6 0.4 -inf];    % Spatial merging threshold [spatial, temporal (raw), temporal (spikes)]

params.merge_thr_fiber = ...       
                  [30 10 15 0.8];        % fiber merging threshold  [distance, paralle distance,angle, temporal correlation]


params.min_corr = 0.1;               % Minimum correlation for seeding
params.min_pnr = 6;                  % Minimum peak-to-noise ratio for seeding

params=CaliAli_parameters(params);
