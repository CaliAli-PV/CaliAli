function Ybg = reconstruct_background_residual(obj, frame_range)
            %%reconstruct background using the saved data
            % input:
            %   frame_range:  [frame_start, frame_end], the range of frames to be loaded
            %% Author: Pengcheng Zhou, Columbia University, 2017
            %% email: zhoupc1988@gmail.com
            
            %% process parameters
            
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
            % reconstruct the constant baseline
            if strcmpi(bg_model, 'ring')
                b0_ = obj.reconstruct_b0();
                b0_new_ = obj.reshape(obj.b0_new, 2);
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
                    b0_ring = b0_(tmp_block(1):tmp_block(2), tmp_block(3):tmp_block(4));
                    b0_ring = reshape(b0_ring, [], 1);
                    
                    b0_patch = reshape(b0_new_(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4)), [], 1);
                    
                    % find the neurons that are within the block
                    mask = zeros(d1, d2);
                    mask(tmp_block(1):tmp_block(2), tmp_block(3):tmp_block(4)) = 1;
                    ind = (reshape(mask(:), 1, [])* obj.A_prev>0);
                    
                    A_patch = obj.A_prev(logical(mask), ind);
                    C_patch = obj.C_prev(ind,frame_range(1):frame_range(2));
                    
                    % reconstruct background
                    %                     Cmean = mean(C_patch , 2);
                    Ypatch = bsxfun(@minus, double(Ypatch), b0_ring);
                    %                     b0_ring = b0_(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4));
                    %                     b0_ring = reshape(b0_ring, [], 1);
                    %
                    if bg_ssub==1
                        Bf = W_ring*(double(Ypatch) - A_patch*C_patch);
                        Ybg(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4),:) = reshape(bsxfun(@plus, Bf, b0_patch), diff(tmp_patch(1:2))+1, [], T);
                    else
                        [d1s, d2s] = size(imresize(zeros(nr_block, nc_block), 1/bg_ssub));
                        temp = reshape(double(Ypatch)-A_patch*C_patch, nr_block, nc_block, []);
                        temp = imresize(temp, 1./bg_ssub, 'nearest');
                        Bf = reshape(W_ring*reshape(temp, [], T), d1s, d2s, T);
                        Bf = imresize(Bf, [nr_block, nc_block], 'nearest');
                        Bf = Bf((tmp_patch(1):tmp_patch(2))-tmp_block(1)+1, (tmp_patch(3):tmp_patch(4))-tmp_block(3)+1, :);
                        Bf = reshape(Bf, [], T);
                        Ybg(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4),:) = reshape(bsxfun(@plus, Bf, b0_patch), diff(tmp_patch(1:2))+1, [], T);
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