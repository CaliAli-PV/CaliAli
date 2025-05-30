function obj=update_spatial_CaliAli(obj, use_parallel,F)
%% update_spatial_CaliAli - Updates the spatial components of extracted neuronal signals.
%
% This function refines the spatial footprints of detected neurons by processing
% data in multiple batches. It updates the spatial maps (A) based on activity
% levels while accounting for spatial variability, ensuring robust separation
% of overlapping components.
%
% Inputs:
%   - obj: CNMF object containing spatial and temporal components.
%   - use_parallel: Boolean flag for enabling parallel processing.
%   - F (optional): Array specifying batch sizes for processing. If not provided,
%     it is determined using get_batch_size(obj).
%
% Outputs:
%   - obj: Updated CNMF object with refined spatial components.
%
%
% Usage:
%   neuron = update_spatial_CaliAli(neuron, true);
%   neuron = update_spatial_CaliAli(neuron, false, batch_frames);
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

fprintf('\n-----------------UPDATE SPATIAL---------------------------\n');
if ~(exist('F','var') && ~isempty(F))
    F=get_batch_size(obj);
end
batch=[0,cumsum(F)];
A_temp=obj.A.*0;
div=length(batch)-1;
obj.A_prev=obj.A;
for i=progress(1:div)
    out_A=update_spatial_in(obj,use_parallel,[batch(i)+1 batch(i+1)],i);
    Ca(:,i)=mean(obj.S(:,batch(i)+1:batch(i+1)),2);
    %      A=max(cat(3,full(A),full(out_A)),[],3);
    A_temp=cat(3,full(A_temp),full(out_A));
end
Ca=Ca.^2;
Ca=Ca./sum(Ca,2);
for i=1:size(Ca,1)
    A(:,i)=sum(squeeze(A_temp(:,i,2:end)).*Ca(i,:),2);
end

obj.A=sparse(A);
end





function out_A=update_spatial_in(neuron, use_parallel,max_frame,idx, update_sn)
%% update the the spatial components for all neurons
% input:
%   use_parallel: boolean, do initialization in patch mode or not.
%       default(true); we recommend you to set it false only when you want to debug the code.
%   update_sn:  boolean, update noise level for each pixel

%% Author: Pengcheng Zhou, Columbia University, 2017
%% email: zhoupc1988@gmail.com

%% process parameters

try
    % map data
    mat_data = neuron.P.mat_data;

    % folders and files for saving the results
    log_file =  neuron.P.log_file;
    flog = fopen(log_file, 'a');
    log_data = matfile(neuron.P.log_data, 'Writable', true); %#ok<NASGU>

    % dimension of data
    dims = mat_data.dims;
    d1 = dims(1);
    d2 = dims(2);
    T = dims(3);
    neuron.options.d1 = d1;
    neuron.options.d2 = d2;

    % parameters for patching information
    patch_pos = mat_data.patch_pos;
    block_pos = mat_data.block_pos;

    % number of patches
    [nr_patch, nc_patch] = size(patch_pos);
catch
    error('No data file selected');
end

% frames to be loaded
frame_range = max_frame;
T = diff(frame_range) + 1;
if isempty(neuron.C_prev)
    neuron.C_prev=neuron.C;
end

% threshold for detecting large residuals
% thresh_outlier = obj.options.thresh_outlier;

% use parallel or not
if ~exist('use_parallel', 'var')||isempty(use_parallel)
    use_parallel = true; %don't save initialization procedure
end
% update sn or not
if ~exist('update_sn', 'var')||isempty(update_sn)
    update_sn = false; %don't save initialization procedure
end
% options
options = neuron.options;
bg_model = options.background_model;
bg_ssub = options.bg_ssub;
method = options.spatial_algorithm;
ca_options=neuron.CaliAli_options;

%% determine search location for each neuron
search_method = options.search_method;
if strcmpi(search_method, 'dilate')
    neuron.options.se = [];
end

if strcmpi(search_method, 'grow')
    IND = sparse(active_contour_grow(neuron)); %NOTE NEED TO ADD GROW PARAMETER TO CALIALI OPTIONS< NOW THIS IS FIXED TO 18 pxl
else
    IND = sparse(logical(determine_search_location(neuron.A, search_method, options)));
end
%% identify existing neurons within each patch
A = cell(nr_patch, nc_patch);
C = cell(nr_patch, nc_patch);
% if strcmpi(bg_model, 'ring')
A_prev = A;
C_prev = C;
% end
sn = cell(nr_patch, nc_patch);
ind_neurons = cell(nr_patch, nc_patch);
IND_search = cell(nr_patch, nc_patch);
with_neuron = cell(nr_patch, nc_patch);
for mpatch=1:(nr_patch*nc_patch)
    tmp_patch = patch_pos{mpatch};
    tmp_block = block_pos{mpatch};
    % find the neurons that are within the block
    mask = zeros(d1, d2);
    mask(tmp_block(1):tmp_block(2), tmp_block(3):tmp_block(4)) = 1;
    mask(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4)) = 2;
    % find neurons within the patch
    ind = find(reshape(mask(:)==2, 1, [])* full(double(IND))>0);
    A{mpatch}= neuron.A((mask>0), ind);
    IND_search{mpatch} = IND(mask==2, ind);
    sn{mpatch} = neuron.P.sn(mask==2);
    C{mpatch} = neuron.C(ind, max_frame(1):max_frame(2));
    ind_neurons{mpatch} = ind;    % indices of the neurons within each patch
    with_neuron{mpatch} = ~isempty(ind);

    if strcmpi(bg_model, 'ring')
        ind = find(reshape(mask(:)==1, 1, [])* full(neuron.A_prev)>0);
        A_prev{mpatch}= neuron.A_prev((mask>0), ind);
        C_prev{mpatch} = neuron.C_prev(ind, max_frame(1):max_frame(2));
    end
end
if update_sn
    sn_new = sn;
end
%% prepare for the variables for computing the background.
bg_model = neuron.options.background_model;
W = neuron.W;
b0 = neuron.b0;
b = neuron.b;
f = neuron.f;

%% start updating spatial components
A_new = A;
tmp_obj = Sources2D();
tmp_obj.options = neuron.options;
if use_parallel
   parfor mpatch=1:(nr_patch*nc_patch) % this is parfor
        [r, c] = ind2sub([nr_patch, nc_patch], mpatch);

        % no neurons, no need to update sn
        flag_neuron = with_neuron{mpatch};
        if (~flag_neuron) && (~update_sn)
            % fprintf('Patch (%2d, %2d) is done. %2d X %2d patches in total. \n', r, c, nr_patch, nc_patch);
            continue;
        end
        % prepare for updating model variablesind_patch
        [r, c] = ind2sub([nr_patch, nc_patch], mpatch);

        tmp_patch = patch_pos{mpatch};     %[r0, r1, c0, c1], patch location
        tmp_block = block_pos{mpatch};

        A_patch = A{mpatch};
        C_patch = C{mpatch};                % previous estimation of neural activity
        IND_patch = IND_search{mpatch};
        nr = diff(tmp_patch(1:2)) + 1;
        nc = diff(tmp_patch(3:4)) + 1;

        % use ind_patch to indicate pixels within the patch
        ind_patch = false(diff(tmp_block(1:2))+1, diff(tmp_block(3:4))+1);
        ind_patch((tmp_patch(1):tmp_patch(2))-tmp_block(1)+1, (tmp_patch(3):tmp_patch(4))-tmp_block(3)+1) = true;

        % get data
        if strcmpi(bg_model, 'ring')
            % including areas outside of the patch for recorving background
            % in the ring model
            Ypatch = get_patch_data(mat_data, tmp_patch, frame_range, true);
        else
            Ypatch = get_patch_data(mat_data, tmp_patch, frame_range, false);
        end
        [nr_block, nc_block, ~] = size(Ypatch);

        % get the noise level
        sn_patch = sn{mpatch};

        % get background
        if strcmpi(bg_model, 'ring')
            A_patch_prev = A_prev{mpatch};
            C_patch_prev = C_prev{mpatch};
            W_ring = W{mpatch};
            b0_ring = b0{mpatch};
            Ypatch = reshape(Ypatch, [], T);

            if ~isempty(A_patch_prev*C_patch_prev) %added by PV;
                tmp_Y = double(Ypatch)-A_patch_prev*C_patch_prev;
            else%added by PV;
                tmp_Y = double(Ypatch);
            end

            if bg_ssub==1
                Ypatch = bsxfun(@minus, double(Ypatch(ind_patch,:))- W_ring*tmp_Y, b0_ring-W_ring*mean(tmp_Y, 2));
            else
                % get the dimension of the downsampled data
                [d1s, d2s] = size(imresize(zeros(nr_block, nc_block), 1/bg_ssub));
                % downsample data and reconstruct B^f
                temp = reshape(bsxfun(@minus, tmp_Y, mean(tmp_Y, 2)), nr_block, nc_block, []);
                temp = imresize(temp, 1./bg_ssub);
                Bf = reshape(W_ring*reshape(temp, [], T), d1s, d2s, T);
                Bf = imresize(Bf, [nr_block, nc_block]);
                Bf = reshape(Bf, [], T);

                Ypatch = bsxfun(@minus, double(Ypatch(ind_patch, :)) - Bf(ind_patch, :), b0_ring);
            end
        elseif strcmpi(bg_model, 'nmf')
            b_nmf = b{mpatch};
            f_nmf = f{mpatch}(max_frame(1):max_frame(2));
            Ypatch = double(reshape(Ypatch, [], T))- b_nmf*f_nmf;
        else
            b_svd = b{mpatch};
            f_svd = f{mpatch}(max_frame(1):max_frame(2));
            b0_svd = b0{mpatch};
            Ypatch = double(reshape(Ypatch, [], T)) - bsxfun(@plus, b_svd*f_svd, b0_svd);
        end

        % using HALS to update spatial components
        if update_sn
            sn_patch = GetSn(Ypatch);
            sn_new{mpatch} = reshape(sn_patch, nr, nc);
        end
        if ~flag_neuron
            % fprintf('Patch (%2d, %2d) is done. %2d X %2d patches in total. \n', r, c, nr_patch, nc_patch);
            continue;
        end
        A_patch = A_patch(ind_patch(:), :);

        %         temp = HALS_spatial(Ypatch, A_patch, C_patch, IND_patch, 3);
        if strcmpi(method, 'hals')
            temp = HALS_spatial(Ypatch, A_patch, C_patch, IND_patch, 3);
        elseif strcmpi(method, 'hals_thresh')
            temp = HALS_spatial_thresh(Ypatch, A_patch, C_patch, IND_patch, 3, sn_patch);
        elseif strcmpi(method, 'lars')
            temp = lars_spatial(Ypatch, A_patch, C_patch, IND_patch, sn_patch);
            %         elseif strcmpi(method, 'nnls_thresh')&&(~isempty(IND_patch))
            %             temp = nnls_spatial_thresh(Ypatch, A_patch, C_patch, IND_patch, 5, sn_patch);
        elseif strcmpi(method, 'hessian')
            temp = HALS_spatial_hessian(Ypatch, A_patch, C_patch,IND_patch,5,ca_options,nr, nc);
        else
            temp = nnls_spatial(Ypatch, A_patch, C_patch, IND_patch, 20);
        end
        %         A_new{mpatch} = tmp_obj.post_process_spatial(reshape(full(temp), nr, nc, []));
        A_new{mpatch} = full(temp);
        % fprintf('Patch (%2d, %2d) is done. %2d X %2d patches in total. \n', r, c, nr_patch, nc_patch);
    end
else
    for mpatch=1:(nr_patch*nc_patch)
        [r, c] = ind2sub([nr_patch, nc_patch], mpatch);

        % no neurons, no need to update sn
        flag_neuron = with_neuron{mpatch};
        if (~flag_neuron) && (~update_sn)
            % fprintf('Patch (%2d, %2d) is done. %2d X %2d patches in total. \n', r, c, nr_patch, nc_patch);
            continue;
        end
        % prepare for updating model variables
        tmp_patch = patch_pos{mpatch};     %[r0, r1, c0, c1], patch location
        tmp_block = block_pos{mpatch};

        A_patch = A{mpatch};
        C_patch = C{mpatch};                % previous estimation of neural activity
        IND_patch = IND_search{mpatch};
        nr = diff(tmp_patch(1:2)) + 1;
        nc = diff(tmp_patch(3:4)) + 1;

        % use ind_patch to indicate pixels within the patch
        ind_patch = false(diff(tmp_block(1:2))+1, diff(tmp_block(3:4))+1);
        ind_patch((tmp_patch(1):tmp_patch(2))-tmp_block(1)+1, (tmp_patch(3):tmp_patch(4))-tmp_block(3)+1) = true;

        % get data
        if strcmpi(bg_model, 'ring')
            % including areas outside of the patch for recorving background
            % in the ring model
            Ypatch = get_patch_data(mat_data, tmp_patch, frame_range, true);
        else
            Ypatch = get_patch_data(mat_data, tmp_patch, frame_range, false);
        end
        [nr_block, nc_block, ~] = size(Ypatch);

        % get the noise level
        sn_patch = sn{mpatch};

        % get background
        if strcmpi(bg_model, 'ring')
            A_patch_prev = A_prev{mpatch};
            C_patch_prev = C_prev{mpatch};
            W_ring = W{mpatch};
            b0_ring = b0{mpatch};
            Ypatch = reshape(Ypatch, [], T);
            tmp_Y = double(Ypatch)-A_patch_prev*C_patch_prev;

            if bg_ssub==1
                Ypatch = bsxfun(@minus, double(Ypatch(ind_patch,:))- W_ring*tmp_Y, b0_ring-W_ring*mean(tmp_Y, 2));
            else
                % get the dimension of the downsampled data
                [d1s, d2s] = size(imresize(zeros(nr_block, nc_block), 1/bg_ssub));
                % downsample data and reconstruct B^f
                temp = reshape(bsxfun(@minus, tmp_Y, mean(tmp_Y, 2)), nr_block, nc_block, []);
                temp = imresize(temp, 1./bg_ssub);
                Bf = reshape(W_ring*reshape(temp, [], T), d1s, d2s, T);
                Bf = imresize(Bf, [nr_block, nc_block]);
                Bf = reshape(Bf, [], T);

                Ypatch = bsxfun(@minus, double(Ypatch(ind_patch, :)) - Bf(ind_patch, :), b0_ring);
            end
        elseif strcmpi(bg_model, 'nmf')
            b_nmf = b{mpatch};
            f_nmf = f{mpatch}(max_frame(1):max_frame(2));
            Ypatch = double(reshape(Ypatch, [], T))- b_nmf*f_nmf;
        else
            b_svd = b{mpatch};
            f_svd = f{mpatch}(max_frame(1):max_frame(2));
            b0_svd = b0{mpatch};
            Ypatch = double(reshape(Ypatch, [], T)) - bsxfun(@plus, b_svd*f_svd, b0_svd);
        end

        % using HALS to update spatial components
        if update_sn
            sn_patch = GetSn(Ypatch);
            sn_new{mpatch} = reshape(sn_patch, nr, nc);
        end
        if ~flag_neuron
            continue;
        end
        A_patch = A_patch(ind_patch, :);

        %         temp = HALS_spatial(Ypatch, A_patch, C_patch, IND_patch, 3);
        if strcmpi(method, 'hals')
            temp = HALS_spatial(Ypatch, A_patch, C_patch, IND_patch, 3);
        elseif strcmpi(method, 'hals_thresh')
            temp = HALS_spatial_thresh(Ypatch, A_patch, C_patch, IND_patch, 3, sn_patch);
        elseif strcmpi(method, 'lars')
            temp = lars_spatial(Ypatch, A_patch, C_patch, IND_patch, sn_patch);
            %         elseif strcmpi(method, 'nnls_thresh')&&(~isempty(IND_patch))
            %             temp = nnls_spatial_thresh(Ypatch, A_patch, C_patch, IND_patch, 5, sn_patch);
        elseif strcmpi(method, 'hessian')
            temp = HALS_spatial_hessian(Ypatch, A_patch, C_patch,IND_patch,5,ca_options,nr, nc);
        else
            temp = nnls_spatial(Ypatch, A_patch, C_patch, IND_patch, 20);
        end
        %         A_new{mpatch} = tmp_obj.post_process_spatial(reshape(full(temp), nr, nc, []));
        A_new{mpatch} = full(temp);
    end
end

%% collect results
K = size(neuron.A, 2);
A_ = zeros(d1, d2, K);
for mpatch=1:(nr_patch*nc_patch)
    A_patch = A_new{mpatch};
    tmp_pos = patch_pos{mpatch};
    nr = diff(tmp_pos(1:2))+1;
    nc = diff(tmp_pos(3:4))+1;
    ind_patch = ind_neurons{mpatch};
    for m=1:length(ind_patch)
        k = ind_patch(m);
        A_(tmp_pos(1):tmp_pos(2), tmp_pos(3):tmp_pos(4), k) = reshape(A_patch(:, m), nr, nc, 1);
    end
end
A_new = sparse(neuron.reshape(A_, 1));
if update_sn
    neuron.P.sn = cell2mat(sn_new);
end
%% post-process results
out_A = neuron.post_process_spatial(neuron.reshape(A_new, 2));
% obj.A = A_new;
%% upadte b0
if strcmpi(bg_model, 'ring')
    neuron.b0_new = neuron.P.Ymean{idx}-neuron.reshape(neuron.A*mean(neuron.C,2), 2); %-obj.reconstruct();
end


%% save the results to log

if neuron.options.save_intermediate
    spatial.A = neuron.A;
    spatial.ids = neuron.ids;
    temporal.b0 = neuron.b0;
    tmp_str = get_date();
    tmp_str=strrep(tmp_str, '-', '_');
    eval(sprintf('log_data.spatial_%s = spatial;', tmp_str));
end
fclose(flog);
end