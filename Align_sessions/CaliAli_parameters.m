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

struct_param={};
if isstruct(varargin{1})
    struct_param = [fieldnames(varargin{1}), struct2cell(varargin{1})]';
    varargin(1)=[];
end
NameValue_param={};
if numel(varargin)>1
    NameValue_param=[varargin(1:2:end), varargin(2:2:end)]';
end

varargin=[struct_param,NameValue_param];


%% Downsampling Parameters
opt.downsampling=downsampling_parameters( ...
    check_CaliAli_structure(varargin,'downsampling'));
%% Preporcessing parameters (Detrending and background pre-processing)
varargin = extend_var(varargin,opt.downsampling);
opt.preprocessing=preprocessing_parameters( ...
    check_CaliAli_structure(varargin,'preprocessing'));
%% Motion correction parameters
varargin = extend_var(varargin,opt);
opt.motion_correction=motion_correction_parameters( ...
    check_CaliAli_structure(varargin,'motion_correction'));
opt.motion_correction.preprocessing=opt.preprocessing;
opt.motion_correction.preprocessing.detrend=false;
opt.motion_correction.preprocessing.noise_scale=0;
%% Inter-session alignment parameters
varargin = extend_var(varargin,opt.motion_correction);
opt.inter_session_alignment=inter_session_alignment_parameters( ...
    check_CaliAli_structure(varargin,'inter_session_alignment'));
opt.inter_session_alignment.preprocessing=opt.preprocessing;
%% CNMF-E parameters
varargin = extend_var(varargin,opt.inter_session_alignment);
opt.cnmf=CNMFE_parameters(check_CaliAli_structure(varargin,'cnmf'));
end


function opt=downsampling_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
inp.PartialMatching = false;
valid_pos_scalar = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x > 0);
valid_optional_pos_scalar = @(x) isempty(x) || valid_pos_scalar(x);
valid_char = @(x) ischar(x) || (isstring(x) && isscalar(x));
%% General variables
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',[],valid_optional_pos_scalar)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',10,valid_pos_scalar)             %Frame rate. Defualt 10 fps
addParameter(inp,'BVsize',[])                 %Size of blood vessels [min diameter max diameter] in pixels.
% defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig];
addParameter(inp,'spatial_ds',1,valid_pos_scalar)      %Spatial Downsampling factor
addParameter(inp,'temporal_ds',1,valid_pos_scalar)     %Temporal Downsampling factor

addParameter(inp,'file_extension','avi',valid_char)      % if a folder is selected instead of a single video file,
% Concatenate all videos with the specified file extension

varargin=varargin{:};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;

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
valid_batch_input = @(x) (isnumeric(x) && isscalar(x) && isfinite(x) && (x >= 0)) || ...
    (ischar(x) && strcmpi(x,'auto')) || (isstring(x) && isscalar(x) && strcmpi(x,'auto'));
%% General
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',[],valid_optional_pos_scalar)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',[],valid_optional_pos_scalar)             %Frame rate. Defualt 10 fps
addParameter(inp,'BVsize',[])                 %Size of blood vessels [min diameter max diameter] in pixels.
% defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig];
addParameter(inp,'preprocessing',[])
addParameter(inp,'batch_sz','auto',valid_batch_input)                % Batch size for chunked processing. 0 = process entire files
addParameter(inp,'Mask',[])                   % Motion correction Mask
%% Motion correction parameters
addParameter(inp,'do_non_rigid',false,valid_bool_scalar)        %Do non-rigid registration
addParameter(inp, ...
    'reference_projection_rigid','BV')     %Reference projections used for translation. Valid parameters are 'BV' or 'neurons'
addParameter(inp, ...
    'non_rigid_pyramid', ...
    {'BV','BV','neuron'})    %Cell array with the projections used for non-rigid registration.
%Each element in the cell array correspond to one level in the pyramid (ascending order).

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
addParameter(inp,'non_rigid_options',opt_nr)

addParameter(inp, ...
    'non_rigid_batch_size',[20,60],@(x) isnumeric(x) && numel(x)==2 && all(x>0) && diff(x)>=0)             % Possible range of a batch for non-rigid correction. CaliAli while find the optimal size within this range.
varargin=varargin{:};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
if isstring(opt.batch_sz)
    opt.batch_sz = char(opt.batch_sz);
end

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
valid_batch_input = @(x) (isnumeric(x) && isscalar(x) && isfinite(x) && (x >= 0)) || ...
    (ischar(x) && strcmpi(x,'auto')) || (isstring(x) && isscalar(x) && strcmpi(x,'auto'));
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
addParameter(inp,'batch_sz',0,valid_batch_input)                  % Number of frames to use per batch. If batch_sz=0, then the number of frame per batch is equal to the number of frames per_session.


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

varargin=varargin{:};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
if isstring(opt.batch_sz)
    opt.batch_sz = char(opt.batch_sz);
end

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
        input=[struct_param,NameValue_param];
    end
end
end

function in = extend_var(in,opt)
if isfield(opt, 'input_files')  % Prevent 'input_files' to propagate across modules
    opt.input_files = [];
end
in=[in,reshape(struct2varargin(opt), 2, [])];
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

