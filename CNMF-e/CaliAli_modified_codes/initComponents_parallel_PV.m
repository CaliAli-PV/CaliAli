function [obj,Cn_update] = initComponents_parallel_PV(obj, K, frame_range, save_avi, use_parallel, use_prev)
%% initializing spatial/temporal components for calcium imaging data
%% input:
%   K:  scalar, maximum number of neurons
%   frame_range: 1 X 2 vector indicating the starting and ending frames
%   save_avi: save the video of initialization procedure
%   use_parallel: boolean, do initialization in patch mode or not.
%       default(true); we recommend you to set it false only when you want to debug the code.
%   use_prev: boolean, use previous initialization or not
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
    mat_file = mat_data.Properties.Source;
    
    % dimension of data
    dims = mat_data.dims;
    d1 = dims(1);
    d2 = dims(2);
    T = dims(3);
    obj.options.d1 = d1;
    obj.options.d2 = d2;
    % frames to be loaded for initialization
    if ~exist('frame_range', 'var')
        frame_range = obj.frame_range;
    end
    if isempty(frame_range)
        frame_range = [1, T];
    else
        frame_range(frame_range<1) = 1;
        frame_range(frame_range>T) = T;
    end
    T = diff(frame_range) + 1;
    obj.frame_range = frame_range;
    
    % folders and files for saving the results
    tmp_dir = sprintf('%s%sframes_%d_%d%s', fileparts(mat_file),filesep, frame_range(1), frame_range(2), filesep);
    if ~exist(tmp_dir, 'dir')
        mkdir(tmp_dir);
    end
    log_folder = [tmp_dir,  'LOGS_', get_date(), filesep];
    log_file = [log_folder, 'logs.txt'];
    log_data_file = [log_folder, 'intermediate_results.mat'];
    obj.P.log_folder = log_folder;
    obj.P.log_file = log_file;
    obj.P.log_data = log_data_file;
    log_data = matfile(log_data_file, 'Writable', true);
    
    % scan the previous initialization results
    temp = dir(tmp_dir);
    previous_folder = cell(length(temp),1);
    k = 0;
    for m=1:length(temp)
        if (strfind(temp(m).name, 'LOGS_'))
            k = k + 1;
            previous_folder{k} = temp(m).name;
        end
    end
    
    % create a folder for new log
    mkdir(log_folder);
    
    % manually check whether to re-use the previous results
    if ~exist('use_prev', 'var') || isempty(use_prev)
        use_prev = true;
    end
    if (k > 0) && use_prev
        fprintf('\nYou have ran %d initialization(s). \n', k);
        for m=1:k
            fprintf('* %2d:\t %s\n', m, previous_folder{m});
        end
        fprintf('\t-------------------------- GUIDE --------------------------\n');
        fprintf('\tuse  i to select the one you want to continue your analysis\n');
        fprintf('\ttype -i to remove some previous results from your hard drive\n');
        fprintf('\ttype anything if you want to start a new initialization\n');
        fprintf('\t--------------------------  END  --------------------------\n');
        
        while true
            choice = input('* make your choice:    ');
            if (choice>0) && (choice<=k)
                % reuse this folder and stop the initialization
                try
                    % copy the previous log file
                    log_old = fopen(fullfile(tmp_dir, previous_folder{choice}, 'logs.txt'), 'r');
                    flog = fopen(log_file, 'a');
                    
                    while true
                        temp = fgets(log_old);
                        fprintf(flog, '%s',temp);
                        
                        if strfind(temp, 'Finished the initialization procedure.') %#ok<*STRIFCND>
                            fclose(log_old);
                            break;
                        end
                    end
                    fclose(flog);
                    
                    % copy the previous results
                    data = matfile(fullfile(tmp_dir, previous_folder{1}, 'intermediate_results.mat'));
                    log_data.initialization = data.initialization;
                    log_data.options_0 = data.options_0;
                    previous_init = data.initialization;
                    center = previous_init.center;
                    Cn = previous_init.Cn;
                    PNR = previous_init.PNR;
                    neuron = previous_init.neuron;
                    obj.A = neuron.A;
                    obj.C = neuron.C;
                    obj.C_raw = neuron.C_raw;
                    obj.S = neuron.S;
                    obj.P = neuron.P;
                    obj.Cn = neuron.Cn;
                    obj.W = neuron.W;
                    obj.b0 = neuron.b0;
                    obj.b = neuron.b;
                    obj.f = neuron.f;
                    obj.P.log_folder = log_folder;
                    obj.P.log_file = log_file;
                    obj.P.log_data = log_data_file;
                    obj.ids = neuron.ids;
                    obj.tags = neuron.tags;
                catch
                    continue;
                end
                try
                    obj.frame_range = neuron.frame_range;
                catch
                    obj.frame_range = [];
                end
                % write this operation to the log file
                flog = fopen(log_file, 'a');
                
                fprintf(flog, '\n--------%s--------\n', get_date());
                fprintf(flog, '[%s]\b', get_minute());
                fprintf(flog, 'Continue the analysis from the previous initialization results:\n\t%s \n\n', previous_folder{choice});
                %                 fprintf('\tContinue the previous initialization  \n\n');
                
                return;
            elseif (choice<0) && (choice>=-k)
                % delete the folder
                try
                    rmdir(fullfile(tmp_dir, previous_folder{-choice}), 's');
                catch
                    continue;
                end
            else
                break;
            end
        end
        
    end
    %
    
    % parameters for patching information
    patch_pos = mat_data.patch_pos;
    block_pos = mat_data.block_pos;
    
    % number of patches
    [nr_patch, nc_patch] = size(patch_pos);
catch
    error('No data file selected');
end


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

% parameters for detrending the data before the initialization.
if isfield(obj.options, 'nk') % number of knots for creating spline basis
    nk = obj.options.nk;
else
    nk = 1;
end
detrend_method = obj.options.detrend_method;

% parameter for avoiding using boundaries pixels as seed pixels
options = obj.options;
if ~isfield(options, 'bd') || isempty(options.bd')
    options.bd = options.gSiz;   % boundary pixesl to be ignored during the process of detecting seed pixels
end
bd = options.bd;
bg_ssub = options.bg_ssub;

%% preallocate spaces for saving model variables relating to background components
bg_model = obj.options.background_model;
W = cell(nr_patch, nc_patch);    % matrix for saving the weight matrix within each block
b0 = cell(nr_patch, nc_patch);   % constant baselines for all pixels
b = cell(nr_patch, nc_patch);
f = cell(nr_patch, nc_patch);
if strcmpi(bg_model, 'ring')
    rr = ceil(obj.options.ring_radius/bg_ssub);    % radius of the ring
    [r_shift, c_shift] = get_nhood(rr, obj.options.num_neighbors);    % shifts used for acquiring the neighboring pixels on the ring
    parfor mpatch=1:(nr_patch*nc_patch)
        tmp_patch = patch_pos{mpatch};    % patch position
        tmp_block = block_pos{mpatch};    % block position
        nr = diff(tmp_patch(1:2)) + 1;
        nc = diff(tmp_patch(3:4)) + 1;
        nr_block = diff(tmp_block(1:2))+1;
        nc_block = diff(tmp_block(3:4))+1;
        b0{mpatch} = zeros(nr*nc, 1);
        
        if bg_ssub==1
            [csub, rsub] = meshgrid(tmp_patch(3):tmp_patch(4), tmp_patch(1):tmp_patch(2));
            csub = reshape(csub, [], 1);
            rsub = reshape(rsub, [], 1);
            ii = repmat((1:numel(csub))', [1, length(r_shift)]);
            csub = bsxfun(@plus, csub, c_shift);
            rsub = bsxfun(@plus, rsub, r_shift);
            ind = and(and(csub>=1, csub<=d2), and(rsub>=1, rsub<=d1));
            jj = (csub-tmp_block(3)) * (diff(tmp_block(1:2))+1) + (rsub-tmp_block(1)+1);
            
            temp = sparse(ii(ind), jj(ind), 1, nr*nc, nr_block*nc_block);
            W{mpatch} = bsxfun(@times, temp, 1./sum(temp, 2));
        else
            d1s = ceil(nr_block/bg_ssub);
            d2s = ceil(nc_block/bg_ssub);
            
            [csub, rsub] = meshgrid(1:d2s, 1:d1s);
            csub = reshape(csub, [], 1);
            rsub = reshape(rsub, [], 1);
            ii = repmat((1:numel(csub))', [1, length(r_shift)]);
            csub = bsxfun(@plus, csub, c_shift);
            rsub = bsxfun(@plus, rsub, r_shift);
            jj = (csub-1) * d1s + rsub;
            % remove neighbors that are out of boundary
            ind = and(and(csub>=1, csub<=d2s), and(rsub>=1, rsub<=d1s));
            temp = sparse(ii(ind), jj(ind), 1, d1s*d2s, d1s*d2s);
            W{mpatch} = bsxfun(@times, temp, 1./sum(temp, 2));
        end
    end
elseif strcmpi(bg_model, 'nmf')
    nb = obj.options.nb;
    for mpatch=1:(nr_patch*nc_patch)
        [r, c] = ind2sub([nr_patch, nc_patch], mpatch);   % patch ind
        tmp_patch = patch_pos{r, c};    % patch position
        nr = diff(tmp_patch(1:2)) + 1;
        nc = diff(tmp_patch(3:4)) + 1;
        b{r, c} = zeros(nr*nc, nb);
        f{r, c} = zeros(nb, T);
    end
else
    %default, SVD model
    nb = obj.options.nb;
    for mpatch=1:(nr_patch*nc_patch)
        [r, c] = ind2sub([nr_patch, nc_patch], mpatch);   % patch ind
        tmp_patch = patch_pos{r, c};    % patch position
        nr = diff(tmp_patch(1:2)) + 1;
        nc = diff(tmp_patch(3:4)) + 1;
        b{r, c} = zeros(nr*nc, nb);
        f{r, c} = zeros(nb, T);
        b0{r, c} = zeros(nr*nc, 1);
    end
end

obj.W = W;
obj.b0 = b0;
obj.b = b;
obj.f = f;
clear W b0 b f;    % remove these variables for saving RAM space

%% start initialization
% save the log infomation
flog = fopen(log_file, 'w');
fprintf(flog, 'Data: %s\n\n', mat_file);
fprintf(flog, '--------%s--------\n', get_date());
fprintf(flog, '[%s]\b', get_minute());
fprintf(flog, 'Start running source extraction......\nThe collection of options are saved as intermediate_results.options_0\n\n');

fprintf(flog, '[%s]\b', get_minute());
fprintf(flog, 'Start initializing neurons from frame %d to frame %d\n\n', frame_range(1), frame_range(2));

[A,C_raw,C,S,Ymean,Cn_update] = int_temp(obj);
%% export the results
obj.A = sparse(A);
obj.C = C;
obj.C_raw = C_raw;
obj.S = sparse(S);
K = size(obj.A, 2);
obj.P.k_ids = K;
obj.ids = (1:K);
obj.tags = zeros(K,1, 'like', uint16(0));
obj.P.Ymean = Ymean;

%% save the results to log
fprintf(flog, '[%s]\b', get_minute());
fprintf(flog, '\tIn total, %d neurons were initialized. \n', K);
% if obj.options.save_intermediate
initialization.neuron = obj.obj2struct();
log_data.initialization = initialization;
fprintf(flog, '\tThe initialization results were saved as intermediate_results.initialization\n\n');
% end
fprintf(flog, 'Finished the initialization procedure.\n');

fclose(flog);
