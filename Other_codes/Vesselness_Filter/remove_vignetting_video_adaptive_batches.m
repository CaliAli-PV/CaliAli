function corrected = remove_vignetting_video_adaptive_batches(Y, scale)
% REMOVE_VIGNETTING_VIDEO_ADAPTIVE_BATCHES
% Normalize vignetting using GPU (batched), CPU-parfor, or direct for single-frame.
%
% Inputs:
%   Y     - 3D array [d1 x d2 x T]
%   scale - Optional, fraction of image size for Gaussian sigma (default = 1/6)
%
% Output:
%   corrected - [d1 x d2 x T] vignetting-corrected video
    Y=single(Y);
    if nargin < 2
        scale = 1/6;
    end

    [d1, d2, T] = size(Y);
    sigma = scale * min(d1, d2);
    corrected = zeros(d1, d2, T, 'like', Y);

    % ---------------- SINGLE FRAME CASE ----------------
    if T == 1
        frame = double(Y(:,:,1));
        background = imgaussfilt(frame, sigma);
        norm_frame = frame ./ (background + eps);
        corrected(:,:,1) = norm_frame / max(norm_frame(:) + eps);
        return
    end

    useGPU = parallel.gpu.GPUDevice.isAvailable;

    if useGPU
        % ---------------- GPU MODE ----------------
        disp('Using GPU with batch slicing...');

        g = gpuDevice;
        freeMB = g.AvailableMemory / 1e6;  % MB

        % Estimate per-frame size in MB
        bytesPerElement = 8;  % double
        MB_per_frame = d1 * d2 * bytesPerElement / 1e6;

        % Allow ~60% of memory for data (conservative)
        maxFramesPerBatch = floor((0.6 * freeMB) / (MB_per_frame * 2));  % x2 due to vignette replication
        maxFramesPerBatch = max(1, min(T, maxFramesPerBatch));  % safety bounds

        disp(['Processing in batches of ', num2str(maxFramesPerBatch), ' frames...']);

        for i = 1:maxFramesPerBatch:T
            batch_idx = i:min(i + maxFramesPerBatch - 1, T);
            batch = double(Y(:,:,batch_idx));  % [d1 x d2 x B]

            % Push to GPU
            batch_gpu = gpuArray(batch);

            % Estimate vignette from mean (of batch)
            mean_frame = mean(batch_gpu, 3);
            background = imgaussfilt(mean_frame, sigma);
            background = repmat(background, 1, 1, numel(batch_idx));

            % Normalize and max-scale
            batch_corrected = batch_gpu ./ (background + eps);
            max_vals = max(max(batch_corrected, [], 1), [], 2);
            batch_corrected = batch_corrected ./ (max_vals + eps);

            % Store back to CPU
            corrected(:,:,batch_idx) = gather(batch_corrected);
        end

    else
        % ---------------- CPU MODE ----------------
        parfor t = 1:T
            frame = double(Y(:,:,t));
            background = imgaussfilt(frame, sigma);
            norm_frame = frame ./ (background + eps);
            corrected(:,:,t) = norm_frame / max(norm_frame(:) + eps);
        end
    end

corrected=v2uint8(corrected);    
end