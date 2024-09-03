function [center, Cn, PNR] = initComponents_residual_parallel(obj, K,frame_range, save_avi, use_parallel, min_corr, min_pnr, seed_method)
%% initializing spatial/temporal components for the residual video
%% input:
%   K:  scalar, maximum number of neurons
%   frame_range: 1 X 2 vector indicating the starting and ending frames
%   save_avi: save the video of initialization procedure
%   use_parallel: boolean, do initialization in patch mode or not.
%       default(true); we recommend you to set it false only when you want to debug the code.

%% Output:
%   center: d*2 matrix, centers of all initialized neurons.
%   Cn:     correlation image
%   PNR:    peak to noise ratio
%% Author: Pengcheng Zhou, Columbia University, 2017
%% email: zhoupc1988@gmail.com

%% process parameters

try
    % map data
    mat_data = obj.P.mat_data;
    
    % folders and files for saving the results
    log_folder = obj.P.log_folder;
    log_file = obj.P.log_file;
    log_data_file = obj.P.log_data;
    log_data = matfile(log_data_file, 'Writable', true); %#ok<NASGU>
    
    % dimension of data
    dims = mat_data.dims;
    d1 = dims(1);
    d2 = dims(2);
    obj.options.d1 = d1;
    obj.options.d2 = d2;
    
    % parameters for patching information
    patch_pos = mat_data.patch_pos;
    block_pos = mat_data.block_pos;
    
    % number of patches
    [nr_patch, nc_patch] = size(patch_pos);
catch
    error('No data file selected');
end
fprintf('\n---------------PICK NEURONS FROM THE RESIDUAL----------------\n');

if exist('min_corr', 'var') && ~isempty(min_corr)
    obj.options.min_corr = min_corr;
end
if exist('min_pnr', 'var') && ~isempty(min_pnr)
    obj.options.min_pnr = min_pnr;
end
if exist('seed_method', 'var') && ~isempty(seed_method)
    obj.options.seed_method = seed_method;
end
% frames to be loaded for initialization
T = diff(frame_range) + 1;

% maximum neuron number in each patch
if (~exist('K', 'var')) || (isempty(K))
    % if K is not specified, use a very large number as default
    K = round((d1*d2));
end

% exporting initialization procedures as a video
if ~exist('save_avi', 'var')||isempty(save_avi)
    save_avi = false; %don't save initialization procedure
elseif save_avi
    use_parallel = false;
end

% use parallel or not
if ~exist('use_parallel', 'var')||isempty(use_parallel)
    use_parallel = true; %don't save initialization procedure
end

% parameter for avoiding using boundaries pixels as seed pixels
options = obj.options;
if ~isfield(options, 'bd') || isempty(options.bd')
    options.bd = options.gSiz;   % boundary pixesl to be ignored during the process of detecting seed pixels
end
bd = options.bd;

if strcmpi(obj.options.seed_method, 'manual')
    use_parallel = false;
end
% no centering of the raw video
% options.center_psf = false;

%% prepare for the variables for computing the background.
bg_model = obj.options.background_model;
bg_ssub = obj.options.bg_ssub;
W = obj.W;
b0 = obj.b0;
b = obj.b;
f = obj.f;

%% the extracted neurons' signals
A = cell(nr_patch, nc_patch);
C = cell(nr_patch, nc_patch);
sn = cell(nr_patch, nc_patch);
ind_neurons = cell(nr_patch, nc_patch);

AA = cell(nr_patch, nc_patch);   % save the ai^T*ai for each neuron

for mpatch=1:(nr_patch*nc_patch)
    if strcmpi(bg_model, 'ring')
        tmp_block = block_pos{mpatch};
    else
        tmp_block = patch_pos{mpatch};
    end
    % find the neurons that are within the block
    mask = zeros(d1, d2);
    mask(tmp_block(1):tmp_block(2), tmp_block(3):tmp_block(4)) = 1;
    ind = (reshape(mask(:), 1, [])* obj.A>0);
    A{mpatch}= obj.A(logical(mask), ind);
    AA{mpatch}= sum(A{mpatch}.^2, 1);
    sn{mpatch} = obj.P.sn(logical(mask));
    C{mpatch} = obj.C(ind, :);
    ind_neurons{mpatch} = find(ind);    % indices of the neurons within each patch
end

%% start initialization
% save the log infomation
k_options = obj.P.k_options +1;
eval(sprintf('log_data.options_%d=options; ', k_options));
obj.P.k_options = k_options;

flog = fopen(log_file, 'a');
fprintf(flog, '[%s]\b', get_minute());
fprintf(flog, 'Start picking neurons from the residual......\n\tThe collection of options are saved as intermediate_results.options_%d\n', k_options);

Ain = cell(nr_patch, nc_patch); % save spatial components of neurons in each patch
Cin = cell(nr_patch, nc_patch); % save temporal components of neurons in each patch, denoised trace
Sin = cell(nr_patch, nc_patch); % save temporal components of neurons in each patch, deconvolved trace
Cin_raw = cell(nr_patch, nc_patch); % save temporal components of neurons in each patch, raw trace
kernel_pars = cell(nr_patch, nc_patch); % save temporal components of neurons in each patch
center = cell(nr_patch, nc_patch);     % save centers of all initialized neurons
Cn = zeros(d1, d2);
PNR = zeros(d1, d2);
default_kernel = obj.kernel;
if isempty(options.Mask)
    options.Mask=true(d1,d2);
end


CaliAli_opt=obj.CaliAli_opt;
n_opt=obj.options;

 Ypatch = obj.load_patch_data([],frame_range);
k=isnan(sum(obj.A));
 Ypatch = double(reshape(Ypatch, [], T)) - full(obj.A(:,~k))*obj.C(~k,:);

Ypatch = Ypatch-double(reshape(reconstruct_background_PV(obj,frame_range), [], T));

[tmp_results, tmp_center, tmp_Cn, tmp_PNR]=greedyROI_endoscope_CaliAli_original(reshape(Ypatch,d1,d2,T),CaliAli_opt,[],n_opt);

%% export the results
obj.A = [obj.A, tmp_results.Ain];
obj.C = [obj.C; tmp_results.Cin];
obj.C_raw = [obj.C_raw; tmp_results.Cin_raw];
if options.deconv_flag
    obj.S = [obj.S; sparse(tmp_results.Sin)];
    obj.P.kernel_pars = [obj.P.kernel_pars; tmp_results.kernel_pars];
else
    obj.S = [obj.S; zeros(size(obj.C))];
end
K = size(Ain, 2);
k_ids = obj.P.k_ids;
obj.ids = [obj.ids, k_ids+(1:K)];
obj.tags = [obj.tags;zeros(K,1, 'like', uint16(0))];
obj.P.k_ids = K+k_ids;
obj.Cnr=tmp_Cn;
obj.PNRr=tmp_PNR;
%% save the results to log

fprintf(flog, '[%s]\b', get_minute());
fprintf(flog, 'Finished the initialization of neurons from the residual video.\n');
fprintf(flog, '\tIn total, %d neurons were detected. \n', size(Ain,2));

if obj.options.save_intermediate
    initialization_res.Ain = sparse(Ain);
    initialization_res.Cin = Cin;
    initialization_res.Cin_raw = Cin_raw;
    initialization_res.options = options;  %#ok<STRNU>
    
    tmp_str = get_date();
    tmp_str=strrep(tmp_str, '-', '_');
    eval(sprintf('log_data.initialization_res_%s = initialization_res;', tmp_str));
    
    fprintf(flog, '\tThe  results were saved as intermediate_results.initialization_res_%s\n\n', tmp_str);
end
fclose(flog);