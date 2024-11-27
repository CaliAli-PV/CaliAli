function opt=CaliAli_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
%% General variables                                   
varargin=varargin{1, :};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;

%% Downsampling Parameters
opt.downsampling=downsampling_parameters(varargin); 
%% Preporcessing parameters (Detrending and background pre-processing)
opt.preprocessing=preprocessing_parameters(varargin);
%% Motion correction parameters
varargin=cat(2,varargin,'preprocessing',opt.preprocessing);
opt.motion_correction=motion_correction_parameters(varargin);
%% Inter-session alignment parameters
opt.inter_session_alignment=inter_session_alignment_parameters(varargin);
end


function opt=downsampling_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
valid_v = @(x) isnumeric(x);
%% General variables
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',2.5,valid_v)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',10,valid_v)             %Frame rate. Defualt 10 fps
addParameter(inp,'BVsize',[])                 %Size of blood vessels [min diameter max diameter] in pixels. 
                                              % defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig];  
addParameter(inp,'spatial_ds',1,valid_v)      %Spatial Downsampling factor
addParameter(inp,'temporal_ds',1,valid_v)     %Temporal Downsampling factor   

varargin=varargin{1, :};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
if isempty(opt.BVsize)
opt.BVsize=[0.6*opt.gSig,0.9*opt.gSig];
end
end


function opt=preprocessing_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
valid_v = @(x) isnumeric(x);
%% Video pre-processing
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',2.5,valid_v)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',10,valid_v)             %Frame rate. Defualt 10 fps

addParameter(inp,'neuron_enhance',true)       %MIN1PIE background substraciton. True is recommended. default True
addParameter(inp,'noise_scale',true)          %Noise scaling of each pixel. True is recommended. default True
addParameter(inp,'detrend',1)                 %Detrending of slow fluctuation. Temporal window (in seconds) in which local minima is search. 0 means no detrending.
varargin=varargin{1, :};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
end


function opt=motion_correction_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
valid_v = @(x) isnumeric(x);
%% General
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',2.5,valid_v)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',10,valid_v)             %Frame rate. Defualt 10 fps
addParameter(inp,'BVsize',[])                 %Size of blood vessels [min diameter max diameter] in pixels. 
                                              % defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig];  
addParameter(inp,'preprocessing',[])                                                
%% Motion correction parameters
addParameter(inp,'do_non_rigid',false)        %Do non-rigid registration 
addParameter(inp, ...
       'reference_projection_rigid','BV')     %Reference projections used for translation. Valid parameters are 'BV' or 'neurons'
addParameter(inp, ...
       'non_rigid_pyramid', ...
                     {'BV','BV','neuron'})    %Cell array with the projections used for non-rigid registration. 
                                              %Each element in the cell array correspond to one level in the pyramid (ascending order).
                                              
% Non-rigid multi-level registration options. This correspond to the
% parameter used for each level in the pyramid
opt_nr{1,1}  = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',8, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0,'scale',0.5);
opt_nr{2,1} = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',8, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0,'scale',0.8);
opt_nr{3,1} = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',6, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0,'scale',1);
addParameter(inp,'non_rigid_options',opt_nr) 

addParameter(inp, ...
    'non_rigid_batch_size',[20,60])             % Posible range of a batch for non-rigid correction. CaliAli while finde the optimal size within this range.
                %Detrending of slow fluctuation. Temporal window (in seconds) in which local minima is search. 0 means no detrending.
varargin=varargin{1, :};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
if isempty(opt.BVsize)
opt.BVsize=[0.6*opt.gSig,0.9*opt.gSig];
end
end


function opt=inter_session_alignment_parameters(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
valid_v = @(x) isnumeric(x);
%% General variables
addParameter(inp,'input_files',[])            %Cell array containing paths to the input video files
addParameter(inp,'output_files',[])           %Cell array containing paths to the output video of individual sessions
addParameter(inp,'gSig',2.5,valid_v)          %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',10,valid_v)             %Frame rate. Defualt 10 fps
addParameter(inp,'BVsize',[])                 %Size of blood vessels [min diameter max diameter] in pixels. 
                                              % defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig]; 
addParameter(inp,'preprocessing',[])   
%% Inter-session alignment variables
addParameter(inp,'projections', ...
                          'BV+neuron')          % Projeciton used for alignment
addParameter(inp,'final_neurons',0)             % Add an extra alignment iteration utilizing only neuron shapes after CaliAli
addParameter(inp,'Force_BV',0)                  % Force the use of BVz for alignment, even if BVz stability score is low.
addParameter(inp,'batch_sz',0)                  % Number of frames to use per batch. If batch_sz=0, then the number of frame per batch is equal to the number of frames per_session.
addParameter(inp,'out_path',[])                 %Path to store the aligned video
%% Internal variables  

addParameter(inp,'alignment_metrics',[]) % Alignment_metrics  
addParameter(inp,'Mask',[])              % Motion correction Mask  
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

varargin=varargin{1, :};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
if isempty(opt.BVsize)
opt.BVsize=[0.6*opt.gSig,0.9*opt.gSig];
end
end

