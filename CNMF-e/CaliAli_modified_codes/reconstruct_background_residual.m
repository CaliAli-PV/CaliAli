function Ybg = reconstruct_background_residual(obj, frame_range)
            %%reconstruct background using the saved data
            % input:
            %   frame_range:  [frame_start, frame_end], the range of frames to be loaded
            %% Author: Pengcheng Zhou, Columbia University, 2017
            %% email: zhoupc1988@gmail.com
            
            %% process parameters
            % The ring background indexes C_prev by A_prev's columns, so the two
            % must describe the same component set. Every background refit
            % re-syncs them; when the background is only fitted first and last,
            % merging, false-positive removal and residual seeding change the
            % component count in between and this function -- which runs after
            % the loop -- is reached with the pair inconsistent. Same policy as
            % the guards in update_spatial_CaliAli and update_temporal_CaliAli:
            % a snapshot of the wrong size is unusable, so refresh both.
            % A_prev/C_prev must describe the SAME components as A/C, not merely
            % agree with each other: merging and false-positive removal shrink
            % A and C, and a snapshot left at the old count makes the background
            % remove signal for components that no longer exist. Comparing the
            % pair only against itself misses that, because both keep the old
            % count together.
            if isempty(obj.A_prev) || size(obj.A_prev,2)~=size(obj.C_prev,1) ...
                    || size(obj.A_prev,2)~=size(obj.A,2) ...
                    || size(obj.C_prev,1)~=size(obj.C,1)
                obj.A_prev = obj.A;
                obj.C_prev = obj.C;
            end
            % The ring model is fitted against the movie, so the traces removed
            % before fitting it have to be in movie units. After scale_to_noise
            % they are in noise units. See trace_noise_scale.
            C_prev_mu = trace_noise_scale(obj, 'apply', obj.C_prev);
            
            try
                % map data
                mat_data = obj.P.mat_data;
                
                % dimension of data
                dims = mat_data.dims;
                d1 = dims(1);
                d2 = dims(2);
                T = dims(3);
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
            
            if ~exist('frame_range', 'var')||isempty(frame_range)
                frame_range = obj.frame_range;
            end
            if isempty(obj.frame_range)
                frame_shift = 0;
            else
%                 frame_shift = 1 - obj.frame_range(1);
                    frame_shift=0; % PV;
            end
            % frames to be loaded for initialization
            T = diff(frame_range) + 1;
            
            bg_model = obj.options.background_model;
            bg_ssub = obj.options.bg_ssub;
            % reconstruct the constant baseline, one per batch: d1 x d2 x pieces,
            % and the piece each requested frame belongs to
            if strcmpi(bg_model, 'ring')
                [b0_, b0_new_, piece] = batch_baselines(obj, frame_range);
            end
            
            %% start updating the background
            Ybg = zeros(d1, d2, T);
            for mpatch=progress(1:(nr_patch*nc_patch),'Title','Reconstructing background')
                tmp_patch = patch_pos{mpatch};
                if strcmpi(bg_model, 'ring')
                    W_ring = obj.W{mpatch};
                    %                     b0_ring = obj.b0{mpatch};
                    % load data
                    Ypatch = get_patch_data(mat_data, tmp_patch, frame_range, true);
                    [nr_block, nc_block, ~] = size(Ypatch);
                    Ypatch = reshape(Ypatch, [], T);
                    tmp_block = block_pos{mpatch};
                    tmp_patch = patch_pos{mpatch};
                    b0_ring = b0_(tmp_block(1):tmp_block(2), tmp_block(3):tmp_block(4), :);
                    b0_ring = reshape(b0_ring, [], size(b0_, 3));
                    
                    b0_patch = reshape(b0_new_(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4), :), [], size(b0_new_, 3));
                    
                    % find the neurons that are within the block
                    mask = zeros(d1, d2);
                    mask(tmp_block(1):tmp_block(2), tmp_block(3):tmp_block(4)) = 1;
                    ind = (reshape(mask(:), 1, [])* obj.A_prev>0);
                    
                    A_patch = obj.A_prev(logical(mask), ind);
                    C_patch = C_prev_mu(ind,frame_range(1):frame_range(2));
                    
                    % reconstruct background
                    %                     Cmean = mean(C_patch , 2);
                    Ypatch = double(Ypatch) - b0_ring(:, piece);
                    %                     b0_ring = b0_(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4));
                    %                     b0_ring = reshape(b0_ring, [], 1);
                    %
                    if bg_ssub==1
                        Bf = W_ring*(double(Ypatch) - A_patch*C_patch);
                        Ybg(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4),:) = reshape(Bf + b0_patch(:, piece), diff(tmp_patch(1:2))+1, [], T);
                    else
                        [d1s, d2s] = size(imresize(zeros(nr_block, nc_block), 1/bg_ssub));
                        temp = reshape(double(Ypatch)-A_patch*C_patch, nr_block, nc_block, []);
                        temp = imresize(temp, 1./bg_ssub, 'nearest');
                        Bf = reshape(W_ring*reshape(temp, [], T), d1s, d2s, T);
                        Bf = imresize(Bf, [nr_block, nc_block], 'nearest');
                        Bf = Bf((tmp_patch(1):tmp_patch(2))-tmp_block(1)+1, (tmp_patch(3):tmp_patch(4))-tmp_block(3)+1, :);
                        Bf = reshape(Bf, [], T);
                        Ybg(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4),:) = reshape(Bf + b0_patch(:, piece), diff(tmp_patch(1:2))+1, [], T);
                    end
                elseif strcmpi(bg_model, 'nmf')
                    b_nmf = obj.b{mpatch};
                    f_nmf = obj.f{mpatch};
                    Ybg(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4),:) = reshape(b_nmf*f_nmf(:, frame_shift+(frame_range(1):frame_range(2))), diff(tmp_patch(1:2))+1, [], T);
                else
                    b_svd = obj.b{mpatch};
                    f_svd = obj.f{mpatch};
                    b0_svd = obj.b0{mpatch};
                    Ybg(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4),:) = reshape(bsxfun(@plus, b_svd*f_svd(:, frame_shift+(frame_range(1):frame_range(2))), b0_svd), diff(tmp_patch(1:2))+1, [], T);
                end
                
            end
            
        end


function [b0_ring, b0_const, piece] = batch_baselines(obj, frame_range)
%% The constant baseline of each batch the requested frames fall in.
% b0_new held ONE baseline for the whole recording, the one the last temporal
% step left: the median frame of the LAST batch minus the neurons. A batch
% brighter or darker than that one got a residual offset by the difference --
% -20 for a session 20 units darker than the last -- in play_movie and in the
% residual that seeding reads. Each batch now gets its own, from the median
% frame the initialization stored for it and the neurons' mean in that batch,
% and a range that spans batches is split. The same baseline is taken off
% before the ring weights are applied, so the ring term works on the batch's
% fluctuations, as it does when it is fitted. Stored once per batch already
% (P.Ymean), so nothing new is saved.
%
% Without a median per batch -- a neuron whose batches do not match its
% medians -- this falls back to the single b0 and b0_new, as before.
T = diff(frame_range) + 1;
F = get_batch_size(obj);
fn = [0, cumsum(F)];
ym = [];
try
    ym = obj.P.Ymean;
catch
end
if numel(ym) ~= numel(F)
    b0_ring = obj.reconstruct_b0();
    b0_const = obj.reshape(obj.b0_new, 2);
    piece = ones(1, T);
    return
end
in_range = find(fn(1:end-1) < frame_range(2) & fn(2:end) >= frame_range(1));
C_mu = trace_noise_scale(obj, 'apply', obj.C);
b0_const = zeros(obj.options.d1, obj.options.d2, numel(in_range));
piece = zeros(1, T);
for j = 1:numel(in_range)
    i = in_range(j);
    b0_const(:, :, j) = double(ym{i}) - obj.reshape(obj.A*mean(C_mu(:, fn(i)+1:fn(i+1)), 2), 2);
    f1 = max(fn(i)+1, frame_range(1));
    f2 = min(fn(i+1), frame_range(2));
    piece((f1:f2) - frame_range(1) + 1) = j;
end
b0_ring = b0_const;
end

