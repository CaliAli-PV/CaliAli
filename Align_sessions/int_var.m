function opt=int_var(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
valid_v = @(x) isnumeric(x);
addParameter(inp,'gSig',2.5,valid_v)     %Neuron Filter size. 2.5 default.
addParameter(inp,'sf',10,valid_v)        %Frame rate. Defualt 10 fps
addParameter(inp,'n_enhanced',1)         %MIN1PIE background substraciton. True is recommended. default True
addParameter(inp,'theFiles','pickup')    %Cell array containing paths to the input video files, "pickup" let the user choose 
addParameter(inp,'BVz',[])               %Size of blood vessels [min diameter max diameter] in pixels. 
                                         % defaults is in the range range [0.6*opt.gSig,0.9*opt.gSig];
%%                                         
addParameter(inp,'dynamic_spatial',0)    % not currently in use                                   
addParameter(inp,'datename',0)           % not currently in use
%% Internal variables                                         
addParameter(inp,'Mask',[])              % Used internally    
addParameter(inp,'T_Mask',[])            % Used internally  
addParameter(inp,'NR_Mask',[])           % Used internally  
addParameter(inp,'NR_Mask_n',[])         % Used internally  
addParameter(inp,'F',[])                 % Used internally  
addParameter(inp,'T',[])                 % Used internally  
addParameter(inp,'shifts',[])            % Used internally  
addParameter(inp,'shifts_n',[])          % Used internally  
addParameter(inp,'BV_score',[])          % Used internally  
addParameter(inp,'range',[])             % Used internally  
addParameter(inp,'date_v',[])   
varargin=varargin{1, :};
if isstruct(varargin)
    varargin = [fieldnames(varargin), struct2cell(varargin)]';
end

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;

if isempty(opt.BVz)
opt.BVz=[0.6*opt.gSig,0.9*opt.gSig];
end


if strcmpi(opt.theFiles,"pickup")
    opt.theFiles = uipickfiles('FilterSpec','*mc.h5');
end


if ~isempty(opt.theFiles)
[filepath,name]=fileparts(opt.theFiles{end});
opt.out=strcat(filepath,'\',name,'_aligned','.h5');
opt.out_mat=strcat(filepath,'\',name,'_aligned.mat');
else
opt.out=[];
opt.out_mat=[];
end
end