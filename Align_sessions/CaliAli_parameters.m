function opt=CaliAli_parameters(varargin)
%% CaliAli_parameters: Initialize and configure parameters for CaliAli processing.
%
% This function initializes and returns a structured set of parameters for
% different stages of the CaliAli processing pipeline, including downsampling,
% preprocessing, motion correction, inter-session alignment, and CNMF-E.
%
% Inputs:
%   varargin - Variable input arguments, which can be an existing structure
%              or key-value pairs specifying parameters.
%
% Outputs:
%   opt - Structure containing all processing parameters.
%
% Usage:
%   opt = CaliAli_parameters();  % Default parameter initialization
%   opt = CaliAli_parameters(existing_opt);  % Use existing parameter structure
%
% Notes:
%   - Each processing module (downsampling, preprocessing, motion correction,
%     inter-session alignment, and CNMF-E) has its own sub-structure with
%     configurable parameters.
%   - The details of these structures can be found in CaliAli_demo_parameters().
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

%% INTIALIZE VARIABLES

%% INTIALIZE VARIABLES
if isempty(varargin)
    varargin={[]};
end

struct_param={}; given_struct = [];
if isstruct(varargin{1})
    given_struct = varargin{1};
    struct_param = [fieldnames(varargin{1}), struct2cell(varargin{1})]';
    varargin(1)=[];
end
NameValue_param={};
if ~(numel(varargin)==1 && isempty(varargin{1}))
    if mod(numel(varargin),2) ~= 0
        error('CaliAli:InvalidNameValuePair','Name-value inputs must come in pairs.');
    end
    % MATLAB passes varargin as a row cell array, so keep the name/value
    % pairs in 2xN form: row 1 = names, row 2 = values. Concatenating
    % horizontally and transposing gave an Nx1 column ordered n1;n2;v1;v2,
    % which interleaves names and values as soon as there is more than one
    % pair; the rest of this file indexes it as 2xN.
    NameValue_param=[varargin(1:2:end); varargin(2:2:end)];
end

% A supplied struct carries two different kinds of setting, and they must not
% be treated alike:
%   - a TOP-LEVEL field is a pipeline-wide value, the flat namespace
%     (opt.batch_sz = 250 means "everywhere")
%   - a field inside a MODULE substructure applies to that module only
%     (opt.motion_correction.batch_sz = 250 means "here")
% They were previously merged into one list, so one had to outrank the other
% and per-module settings lost.
[module_param, global_param] = split_by_scope(struct_param);

% PRECEDENCE, lowest to highest. uniqueNV keeps the last occurrence, so later
% means higher priority:
%   1. inherited from the module above     (appended by extend_var)
%   2. the module's own stored value       (appended per module, below)
%   3. a NON-EMPTY top-level field         (a pipeline-wide setting)
%   4. a name/value pair in THIS call      (most explicit, appended last)
%
% Why "non-empty". A top-level field is two different things depending on its
% value, and the struct records no provenance to tell them apart. An EMPTY one
% is the seed a parameter started life with -- gSig arrives as [] and is derived
% to 5/spatial_ds by downsampling -- and must lose to the resolved value, or
% every derivation is undone. A NON-EMPTY one is a setting the user made, and
% must win. Dropping the empties separates the two cases without needing to
% track where a value came from.
global_param = drop_empty(global_param);
varargin={};



%% Downsampling Parameters
opt.downsampling=downsampling_parameters( ...
    assemble(varargin,module_param,'downsampling',global_param,NameValue_param));
%% Preporcessing parameters (Detrending and background pre-processing)
varargin = extend_var(varargin,opt.downsampling);
opt.preprocessing=preprocessing_parameters( ...
    assemble(varargin,module_param,'preprocessing',global_param,NameValue_param));
%% Motion correction parameters
varargin = extend_var(varargin,opt);
opt.motion_correction=motion_correction_parameters( ...
    assemble(varargin,module_param,'motion_correction',global_param,NameValue_param));
opt.motion_correction.preprocessing=opt.preprocessing;
opt.motion_correction.preprocessing.detrend=false;
opt.motion_correction.preprocessing.noise_scale=0;
%% Inter-session alignment parameters
varargin = extend_var(varargin,opt.motion_correction);
opt.inter_session_alignment=inter_session_alignment_parameters( ...
    assemble(varargin,module_param,'inter_session_alignment',global_param,NameValue_param));
opt.inter_session_alignment.preprocessing=opt.preprocessing;
%% CNMF-E parameters
varargin = extend_var(varargin,opt.inter_session_alignment);
opt.cnmf=CNMFE_parameters(assemble(varargin,module_param,'cnmf',global_param,NameValue_param));
end


function opt=downsampling_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
inp.PartialMatching = false;
valid_pos_scalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x > 0);
valid_optional_pos_scalar = @(x) isempty(x) || valid_pos_scalar(x);
valid_char = @(x) ischar(x) || (isstring(x) && isscalar(x));
valid_bool_ds = @(x) (islogical(x) && isscalar(x)) || (isnumeric(x) && isscalar(x) && ismember(x,[0 1]));
%% General variables
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',[],valid_optional_pos_scalar)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',10,valid_pos_scalar)             %Frame rate. Defualt 10 fps
addParameter(inp,'BVsize',[])                 %Size of blood vessels [min diameter max diameter] in pixels.
% defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig];
addParameter(inp,'spatial_ds',1,valid_pos_scalar)      %Spatial Downsampling factor
addParameter(inp,'temporal_ds',1,valid_pos_scalar)     %Temporal Downsampling factor
addParameter(inp,'batch_sz','auto',@valid_batch_setting) % Frames per batch. See valid_batch_setting for the named modes.
% Datatype every stage stores the recording in. uint16 covers every scientific
% camera's range at half the memory of single, and every stage downstream
% preallocates in this class, so it has to be decided once and used everywhere.
% The previous behaviour -- cast to uint8 -- clipped anything above 254; simply
% keeping the source class instead meant a float recording used four times the
% memory and was then silently cast back to uint16 at the next stage anyway.
% Datatype the pipeline stores the recording in, for EVERY stage.
%
% There is deliberately one of these rather than one per module. Parameters in
% CaliAli live in a flat namespace and are projected into each module's
% substructure; editing the projection does not work, because the next parse
% flattens it back. So a value that needs to vary per stage has to be a distinct
% flat name, and storage class does not need to vary: a stage that wants headroom
% wants it because the data needs it, which is a property of the recording rather
% than of the stage.
%
% uint16 by default. Sessions concatenated from different recordings can have
% different dynamic ranges, and detrending creates values outside the source
% range, so uint8 is usually too narrow even when the camera was 8-bit. Only
% unsigned integers: the pipeline clips against integer maxima and subtracts
% integers from the data during extraction.
addParameter(inp,'output_class','uint16',@(x) any(strcmpi(char(x), ...
    {'uint8','uint16','uint32'})))

% Sensor-defect repair. Dead pixels, dropped frames and leftover borders are all
% structure that does NOT move with the tissue, and motion correction registers
% against whatever does not move: three dead pixels were enough to collapse a
% session's estimated shifts from a standard deviation of 2.8 pixels to 0.4.
%
% This normally runs inside CaliAli_downsample, on raw frames, because that is
% the only point where a dead pixel is still one pixel. Motion correction,
% alignment and detrending each call it again as a BACKUP, for recordings that
% entered the pipeline late. Whether it has already been done is recorded in the
% CaliAli_options saved inside each FILE, never here -- this struct is shared by
% every file in a call, so a flag living here would mark a second batch as done
% when only the first had been.
addParameter(inp,'repair_defects',true,valid_bool_ds)   % run the repair at all
addParameter(inp,'dead_pixel_factor',0.1,valid_pos_scalar)  % variance below this share of the local median counts as dead
addParameter(inp,'repair_borders',true,valid_bool_ds)   % crop a constant region that reaches the frame edge
addParameter(inp,'defects_repaired',[])                     % the record, written per file, never set by hand

addParameter(inp,'file_extension','avi',valid_char)      % if a folder is selected instead of a single video file,
% Concatenate all videos with the specified file extension

varargin=varargin{:};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
opt.batch_sz = normalize_batch_setting(opt.batch_sz);

if opt.spatial_ds <= 0
    error('CaliAli:InvalidSpatialDownsampling','spatial_ds must be positive.');
end
if opt.temporal_ds <= 0
    error('CaliAli:InvalidTemporalDownsampling','temporal_ds must be positive.');
end
if opt.sf <= 0
    error('CaliAli:InvalidFrameRate','sf must be positive.');
end

if isempty(opt.gSig)
    opt.gSig=5./opt.spatial_ds;
end

if isempty(opt.BVsize)
    opt.BVsize=[0.6*opt.gSig,0.9*opt.gSig];
else
    validateattributes(opt.BVsize,{'numeric'},{'vector','numel',2,'positive','finite'},mfilename,'BVsize');
end

end

function opt=preprocessing_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
inp.PartialMatching = false;
valid_pos_scalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x > 0);
valid_optional_pos_scalar = @(x) isempty(x) || valid_pos_scalar(x);
valid_nonneg_scalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x >= 0);
valid_bool_scalar = @(x) (islogical(x) && isscalar(x)) || (isnumeric(x) && isscalar(x) && ismember(x,[0 1]));
valid_char = @(x) ischar(x) || (isstring(x) && isscalar(x));
%% Video pre-processing
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',[],valid_optional_pos_scalar)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',[],valid_optional_pos_scalar)             %Frame rate. Defualt 10 fps

addParameter(inp,'neuron_enhance',true,valid_bool_scalar)       %MIN1PIE background substraciton. True is recommended. default True
addParameter(inp,'noise_scale',true,valid_bool_scalar)          %Noise scaling of each pixel. True is recommended. default True
addParameter(inp,'detrend',1,valid_nonneg_scalar)                 %Detrending of slow fluctuation. Temporal window (in seconds) in which local minima is search. 0 means no detrending.
addParameter(inp,'remove_BV',false,valid_bool_scalar)           %Remove BV from the neuron-filtered projection]

addParameter(inp,'force_non_negative',1,valid_nonneg_scalar)       %Remove negative values after detrending
addParameter(inp,'force_non_negative_tolerance',20,valid_nonneg_scalar)       %shifts the signal up by that amount before zero-clipping, preserving negative noise fluctuations within that range.

%% Dendrite processing codes. This section is experimental. This is not used unless structure is set to 'dendrite'
% Sensor-defect repair. Dead pixels, dropped frames and leftover borders are all
% structure that does NOT move with the tissue, and motion correction registers
% against whatever does not move: three dead pixels were enough to collapse a
% session's estimated shifts from a standard deviation of 2.8 pixels to 0.4.
%
% This normally runs inside CaliAli_downsample, on raw frames, because that is
% the only point where a dead pixel is still one pixel. Motion correction,
% alignment and detrending each call it again as a BACKUP, for recordings that
% entered the pipeline late. Whether it has already been done is recorded in the
% CaliAli_options saved inside each FILE, never here -- this struct is shared by
% every file in a call, so a flag living here would mark a second batch as done
% when only the first had been.
addParameter(inp,'repair_defects',true,valid_bool_scalar)   % run the repair at all
addParameter(inp,'dead_pixel_factor',0.1,valid_pos_scalar)  % variance below this share of the local median counts as dead
addParameter(inp,'repair_borders',true,valid_bool_scalar)   % crop a constant region that reaches the frame edge
addParameter(inp,'defects_repaired',[])                     % the record, written per file, never set by hand
addParameter(inp,'structure','neuron',valid_char)      % Set up this to 'dendrite' to extract dendrites instead of neurons
addParameter(inp,'dendrite_filter_size',0.5:0.1:0.8,@(x)isnumeric(x)&&all(isfinite(x))&&all(x>0)) % Dendrites filtering size
addParameter(inp, 'dendrite_theta', 30,@(x)isnumeric(x)&&isscalar(x)&&isfinite(x));    % Filter dendrites based on their orientation (degrees).
                                            % 0: No filtering.
                                            % Positive value (0 to +90): Filter out dendrites with orientation < dendrite_theta.
                                            % Negative value (0 to -90): Filter out dendrites with orientation > -dendrite_theta.

addParameter(inp,'fastPNR',false,valid_bool_scalar)           % Avoid calculating the correlation image 
                                            % and use Laplaciang filtering instead (Faster by accuracy havent been tested.)

addParameter(inp,'median_filtering',[],@(x) isempty(x) || (isnumeric(x) && numel(x)==2 && all(x>=1)))    % Apply median filtering to the image 


varargin=varargin{1, :};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
if ~isempty(opt.sf) && opt.sf <= 0
    error('CaliAli:InvalidFrameRate','preprocessing.sf must be positive.');
end
end

function opt=motion_correction_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
inp.PartialMatching = false;
valid_pos_scalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x > 0);
valid_optional_pos_scalar = @(x) isempty(x) || valid_pos_scalar(x);
valid_nonneg_scalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x >= 0);
valid_bool_scalar = @(x) (islogical(x) && isscalar(x)) || (isnumeric(x) && isscalar(x) && ismember(x,[0 1]));
valid_batch_input = @valid_batch_setting;
%% General
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',[],valid_optional_pos_scalar)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',[],valid_optional_pos_scalar)             %Frame rate. Defualt 10 fps
addParameter(inp,'BVsize',[])                 %Size of blood vessels [min diameter max diameter] in pixels.
% defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig];
addParameter(inp,'preprocessing',[])
addParameter(inp,'batch_sz','auto',valid_batch_input)                % Frames per batch. 'auto', 'all_frames', 'per_session' or a number.
% Sensor-defect repair. Dead pixels, dropped frames and leftover borders are all
% structure that does NOT move with the tissue, and motion correction registers
% against whatever does not move: three dead pixels were enough to collapse a
% session's estimated shifts from a standard deviation of 2.8 pixels to 0.4.
%
% This normally runs inside CaliAli_downsample, on raw frames, because that is
% the only point where a dead pixel is still one pixel. Motion correction,
% alignment and detrending each call it again as a BACKUP, for recordings that
% entered the pipeline late. Whether it has already been done is recorded in the
% CaliAli_options saved inside each FILE, never here -- this struct is shared by
% every file in a call, so a flag living here would mark a second batch as done
% when only the first had been.
addParameter(inp,'repair_defects',true,valid_bool_scalar)   % run the repair at all
addParameter(inp,'dead_pixel_factor',0.1,valid_pos_scalar)  % variance below this share of the local median counts as dead
addParameter(inp,'repair_borders',true,valid_bool_scalar)   % crop a constant region that reaches the frame edge
addParameter(inp,'defects_repaired',[])                     % the record, written per file, never set by hand
addParameter(inp,'Mask',[])                   % Motion correction Mask
%% Motion correction parameters
addParameter(inp,'do_non_rigid',false,valid_bool_scalar)        %Do non-rigid registration
addParameter(inp, ...
    'reference_projection_rigid','BV')     %Reference projections used for translation. Valid parameters are 'BV' or 'neurons'
% DEPRECATED, kept only so older scripts still parse. Non-rigid correction is now
% NoRMCorre's piecewise-rigid mode, run inside the same call as the rigid one:
% the frame is split into patches and each gets its own shift, bounded by
% max_dev. The pyramid of demons levels these described belonged to Non_rigid_mc,
% which registered with a KLT tracker and needed the Computer Vision Toolbox.
% Nothing reads them any more. See non_rigid_grid_default for what replaced them.
addParameter(inp, ...
    'non_rigid_pyramid', ...
    {'BV','BV','neuron'})    % DEPRECATED, unused

% Non-rigid multi-level registration options. This correspond to the
% parameter used for each level in the pyramid
opt_nr{1,1}  = struct('stop_criterium',0.001,'imagepad',1.5,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',4, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0,'scale',0.5);
opt_nr{2,1} = struct('stop_criterium',0.001,'imagepad',1.5,'niter',25, 'sigma_fluid',1,...
    'sigma_diffusion',3, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0,'scale',0.8);
opt_nr{3,1} = struct('stop_criterium',0.001,'imagepad',1.5,'niter',50, 'sigma_fluid',1,...
    'sigma_diffusion',3, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0,'scale',1);
addParameter(inp,'non_rigid_options',opt_nr)   % DEPRECATED, unused

addParameter(inp, ...
    'non_rigid_batch_size',[20,60],@(x) isnumeric(x) && numel(x)==2 && all(x>0) && diff(x)>=0)             % DEPRECATED, unused

% Non-rigid pyramid depth. Level 1 lays 3 patches across each axis, level 2 uses
% 4, and so on, each level registering only the residual the one before it left.
% One level by default: measured on a known 1.5 px deformation, a single 3x3
% leaves 0.802 px while 4x4 alone leaves 0.850 and 5x5 alone 0.873 -- a finer
% grid ON ITS OWN is worse, because each patch holds less signal. It only pays
% inside a cascade, where the fine level has a small residual left to find:
% 3x3 -> 4x4 -> 5x5 -> 6x6 reaches 0.713. Each level costs one more registration
% pass, so the depth is yours to choose.
addParameter(inp,'non_rigid_levels',1,valid_pos_scalar)

% Everything slower than this is removed from the image the non-rigid levels
% register on. See highpass_reference for why it is a high pass and not the
% vessel map the rigid stage uses.
addParameter(inp,'non_rigid_highpass_sigma',6,valid_pos_scalar)
varargin=varargin{:};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
opt.batch_sz = normalize_batch_setting(opt.batch_sz);

if ~isempty(opt.sf) && opt.sf <= 0
    error('CaliAli:InvalidFrameRate','motion_correction.sf must be positive.');
end
if isempty(opt.BVsize)
    opt.BVsize=[0.6*opt.gSig,0.9*opt.gSig];
else
    validateattributes(opt.BVsize,{'numeric'},{'vector','numel',2,'positive','finite'},mfilename,'BVsize');
end
end

function opt=inter_session_alignment_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
inp.PartialMatching = false;
valid_pos_scalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x > 0);
valid_optional_pos_scalar = @(x) isempty(x) || valid_pos_scalar(x);
valid_nonneg_scalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x >= 0);
valid_bool_scalar = @(x) (islogical(x) && isscalar(x)) || (isnumeric(x) && isscalar(x) && ismember(x,[0 1]));
valid_batch_input = @valid_batch_setting;
%% General variables
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'out_aligned_sessions',[])                 %Path to store the aligned video
addParameter(inp,'gSig',[],valid_optional_pos_scalar)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',[],valid_optional_pos_scalar)             %Frame rate. Defualt 10 fps
addParameter(inp,'BVsize',[])                 %Size of blood vessels [min diameter max diameter] in pixels.
% defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig];
addParameter(inp,'do_alignment_translation',true,valid_bool_scalar)       % Do inter-session aligment. If false video will be concatenated without correcting translation missalignments.
addParameter(inp,'do_alignment_non_rigid',true,valid_bool_scalar)         % Do inter-session aligment. If false video will be concatenated without correcting non-rigid missalignments.

addParameter(inp,'preprocessing',[])
%% Inter-session alignment variables
addParameter(inp,'projections', ...
    'BV+neuron')          % Projeciton used for alignment
addParameter(inp,'final_neurons',0)             % Add an extra alignment iteration utilizing only neuron shapes after CaliAli
addParameter(inp,'Force_BV',0)                  % Force the use of BVz for alignment, even if BVz stability score is low.
% Frames per batch, for the steps that run after the sessions are concatenated.
% 'per_session' keeps the batches aligned with the session boundaries, which is
% what the legacy value 0 meant here; 'all_frames' takes the whole concatenated
% recording in one batch; 'auto' sizes them against the free memory. The default
% is 'auto' to match the value this module inherits from the one above it when
% nothing is set, which is what has decided the batching in practice.
addParameter(inp,'batch_sz','auto',valid_batch_input)


%% Defening video batches corresponding to the same session
% In some cases, the available memory may not be sufficient to process a full
% individual session. To handle this, video files can be split into smaller
% segments. When doing so, we need to inform CaliAli which files belong to
% the same original session. For those files, non-rigid inter-session alignment
% will be skipped.
%
% Usage example:
% If you have 4 files—2 belonging to session A and 2 to session B—
% specify the session grouping as:
% same_ses_id = [1, 1, 2, 2];

% Sensor-defect repair. Dead pixels, dropped frames and leftover borders are all
% structure that does NOT move with the tissue, and motion correction registers
% against whatever does not move: three dead pixels were enough to collapse a
% session's estimated shifts from a standard deviation of 2.8 pixels to 0.4.
%
% This normally runs inside CaliAli_downsample, on raw frames, because that is
% the only point where a dead pixel is still one pixel. Motion correction,
% alignment and detrending each call it again as a BACKUP, for recordings that
% entered the pipeline late. Whether it has already been done is recorded in the
% CaliAli_options saved inside each FILE, never here -- this struct is shared by
% every file in a call, so a flag living here would mark a second batch as done
% when only the first had been.
addParameter(inp,'repair_defects',true,valid_bool_scalar)   % run the repair at all
addParameter(inp,'dead_pixel_factor',0.1,valid_pos_scalar)  % variance below this share of the local median counts as dead
addParameter(inp,'repair_borders',true,valid_bool_scalar)   % crop a constant region that reaches the frame edge
addParameter(inp,'defects_repaired',[])                     % the record, written per file, never set by hand
addParameter(inp,'same_ses_id',[])        % If [], all files will be considered as different sessions.

%% Internal variables

addParameter(inp,'alignment_metrics',[]) % Alignment_metrics
addParameter(inp,'T_Mask',[])            % Post-translation Mask
addParameter(inp,'NR_Mask',[])           % Non-rigid registration Mask
addParameter(inp,'NR_Mask_n',[])         % Final neuron alignment registration Mask
addParameter(inp,'F',[])                 % Frame number in each session
addParameter(inp,'T',[])                 % Translation vector
addParameter(inp,'Cn',[])                % Correlation image
addParameter(inp,'PNR',[])               % Peak2-to-noise ratio image
addParameter(inp,'P',[])                 % Projections (Mean,BV,PNR,Corr,BV+neuron)
addParameter(inp,'shifts',[])            % Non-rigid displacement field
addParameter(inp,'shifts_n',[])          % Final neuron alignment non-rigid displacement field
addParameter(inp,'BV_score',[])          % BV alignment score
addParameter(inp,'range',[])             % Color-bit range of each session
addParameter(inp,'Cn_scale',[])          % Scale of the coorelation image
% Per-session projections, kept rather than collapsed into one image. Cn_scale is
% the peak over EVERY session, so a stage that divides a single session's image
% by it uses the wrong number whenever that session's own peak is lower. These
% are declared here because the parser keeps only what addParameter names:
% inp.KeepUnmatched is true but the struct is taken from inp.Results, so an
% undeclared field is dropped silently on the next pass. See projection_session_stats.
addParameter(inp,'Cn_per_session',[])          % Raw correlation image of each session, aligned grid
addParameter(inp,'PNR_per_session',[])         % Raw peak-to-noise image of each session
addParameter(inp,'Cn_scale_per_session',[])    % Peak correlation of each session on its own
addParameter(inp,'PNR_scale_per_session',[])   % Peak peak-to-noise of each session on its own
addParameter(inp,'projection_method',[])       % Which branch of get_projections_and_detrend produced them
addParameter(inp,'projection_median_filtering',[]) % medfilt2 size applied to them, [] if none

varargin=varargin{:};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
opt.batch_sz = normalize_batch_setting(opt.batch_sz);

if ~isempty(opt.sf) && opt.sf <= 0
    error('CaliAli:InvalidFrameRate','inter_session_alignment.sf must be positive.');
end
if isempty(opt.BVsize)
    opt.BVsize=[0.6*opt.gSig,0.9*opt.gSig];
else
    validateattributes(opt.BVsize,{'numeric'},{'vector','numel',2,'positive','finite'},mfilename,'BVsize');
end
end

function input = check_CaliAli_structure(input,field_name)
% check_fields Checks if a structure has the specified fields.
if ~isempty(input)
    index = find(strcmp(input(1,:), field_name));
    if ~isempty(index)
        struct_param=input{2,index};
        struct_param = [fieldnames(struct_param), struct2cell(struct_param)]';
        NameValue_param=input;
        NameValue_param(:,index)=[];
        % Left for callers that still route a module substructure through here.
        % The per-module list is now assembled by `assemble`, which places the
        % module's own values after the inherited ones deliberately.
        input=[NameValue_param,struct_param];
    end
end
end



function out = drop_empty(nv)
%% Remove name/value columns whose value is empty. See the note on precedence.
out = nv;
if isempty(nv), return; end
keep = ~cellfun(@isempty, nv(2,:));
out = nv(:, keep);
end


function [module_param, global_param] = split_by_scope(struct_param)
%% Separate per-module substructures from pipeline-wide top-level fields.
% A value that is one of the module substructures is scoped to that module;
% anything else at the top level is a flat, pipeline-wide setting.
module_names = {'downsampling','preprocessing','motion_correction', ...
    'inter_session_alignment','cnmf'};
module_param = {}; global_param = {};
if isempty(struct_param), return; end
is_module = ismember(lower(struct_param(1,:)), module_names);
module_param = struct_param(:, is_module);
global_param = struct_param(:, ~is_module);
end


function out = assemble(base, module_param, name, glob, nv)
%% Build one module's parameter list in precedence order, lowest first.
% base          everything inherited from the modules above
% module_param  the per-module substructures supplied by the caller
% name          which module this is
% glob          non-empty top-level fields, i.e. pipeline-wide settings
% nv            name/value pairs given in this call
own = {};
if ~isempty(module_param)
    idx = find(strcmpi(module_param(1,:), name), 1);
    if ~isempty(idx)
        sub = module_param{2, idx};
        if isstruct(sub)
            own = [fieldnames(sub), struct2cell(sub)]';
        end
    end
end
out = [base, own, glob, nv];
if ~isempty(out), out = uniqueNV(out); end
end


function in = extend_var(in,opt)
in=[in,reshape(struct2varargin(opt), 2, [])];
% Prevent file path names from propagating across modules.
mask = strcmpi(in(1,:), 'input_files') | strcmpi(in(1,:), 'output_files');
in(:, mask) = [];

in = uniqueNV(in);
end


function args_raw = struct2varargin(S)
%STRUCT2VARARGIN Convert struct (possibly nested) into varargin-style cell array.
% Keeps the last value for duplicate names.
%
% Example:
%   S = struct('a',1,'b',struct('x',10,'y',20),'a',3);
%   args = struct2varargin(S);
%   % -> {'a',3,'b.x',10,'b.y',20}

assert(isstruct(S) && isscalar(S), 'Input must be a scalar struct.');

% Flatten nested structures
flat = flattenStruct(S);

% Deduplicate (last value wins)
fn = fieldnames(flat);
vals = struct2cell(flat);
args_raw = reshape([fn'; vals'], 1, []);
end

%% ------------------------------------------------------------------------
function flat = flattenStruct(S)
if nargin < 2; end
flat = struct();
f = fieldnames(S);
for i = 1:numel(f)
    val = S.(f{i});
    name = f{i};
    flat.(name) = val;
end
end


%% ------------------------------------------------------------------------
function nv_out = uniqueNV(nv_in)
%UNIQUE-NV  Deduplicate 2xN name–value array, keeping the last value for each name.
% Input:  nv_in = 2xN cell array: [names; values]
% Output: nv_out = 2xM cell array (deduplicated, last occurrence wins)

% --- Validation ---
assert(ismatrix(nv_in) && size(nv_in,1)==2, ...
    'Input must be a 2xN cell array [names; values].');

names = nv_in(1,:);
vals  = nv_in(2,:);
seen = containers.Map('KeyType','char','ValueType','logical');
out_names = {};
out_vals  = {};

% Iterate backward so later-defined values have priority
for k = numel(names):-1:1
    key = lower(char(string(names{k}))); % case-insensitive
    if ~isKey(seen, key)
        out_names = [names(k), out_names];
        out_vals  = [vals(k),  out_vals];
        seen(key) = true;
    end
end

nv_out = [out_names; out_vals];
end


function tf = valid_batch_setting(x)
%% Accept a frame count or one of the named batching modes.
% The named modes exist because the number 0 used to carry two different
% meanings depending on which module read it -- "the whole file at once" in
% downsampling and motion correction, "one batch per session" after the sessions
% are concatenated. 0 is still accepted so old scripts and saved option structs
% keep working; resolve_batch_mode maps it to whichever of the two the reading
% module has always used.
tf = false;
if isstring(x) && isscalar(x), x = char(x); end
if ischar(x)
    tf = any(strcmpi(strtrim(x), {'auto','all_frames','per_session'}));
    return
end
if isnumeric(x) && isscalar(x) && (x >= 0) && (isfinite(x) || isinf(x))
    tf = true;
end
end


function x = normalize_batch_setting(x)
%% Store the named modes in one spelling, so comparisons elsewhere are simple.
if isstring(x) && isscalar(x), x = char(x); end
if ischar(x), x = lower(strtrim(x)); end
end
