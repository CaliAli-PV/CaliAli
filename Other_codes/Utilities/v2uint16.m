function out = v2uint16(in, thr)
% v2uint16: Convert an input array to uint16 with optional thresholding and memory handling
%
% This function normalizes the input array `in` to the range [0, 1] and then
% scales it to uint16 format. It processes the data in batches if the input array
% exceeds the available system memory.
%
% Arguments:
%   - in: Input numeric array to be converted to uint16
%   - thr: (Optional) Two-element vector [lower, upper] specifying the thresholds.
%          Values below `thr(1)` are clamped to `thr(1)`, and values above `thr(2)`
%          are clamped to `thr(2)`.
%
% Returns:
%   - out: Normalized and converted array in uint16 format

% Constants
bytesPerSingle = 4; % Single precision uses 4 bytes per element

% Calculate the memory required for the input array in **GB**
requiredMemory = numel(in) * bytesPerSingle / (1024^3); % Convert bytes to GB

% Get available system memory in GB
[availableMemory, ~] = getSystemMemory();
availableMemory = availableMemory * 0.9; % Use 90% of available memory to prevent overload

% Check if the entire array fits in available memory
if requiredMemory <= availableMemory
    % Process the entire array at once
    in = single(in); % Convert to single precision for normalization
    if exist('thr', 'var') % Apply thresholding if specified
        in(in < thr(1)) = thr(1);
        in(in > thr(2)) = thr(2);
    end
    % Normalize to the range [0, 1] and scale to uint16
    in = (in - min(in, [], 'all')) ./ range(in, 'all');
    out = uint16(in * 2^16); % Scale to 16-bit range

else
    % Memory required per slice (in **GB**)
    sliceMemory = size(in, 1) * size(in, 2) * bytesPerSingle / (1024^3);

    % Calculate the number of slices that fit in the available memory
    slicesPerBatch = max(floor(availableMemory / sliceMemory), 1); % Ensure at least one slice per batch

    % Total number of slices in the 3rd dimension
    numSlices = size(in, 3);

    % Generate batch indices based on the number of slices per batch
    x = round(linspace(0, numSlices, ceil(numSlices / slicesPerBatch) + 1));

    % Process data in batches
    out = cell(1, numel(x) - 1); % Preallocate output as a cell array
    for i = 1:numel(x) - 1
        temp = single(in(:, :, x(i) + 1:x(i + 1))); % Extract batch slices
        if exist('thr', 'var') % Apply thresholding if specified
            temp(temp < thr(1)) = thr(1);
            temp(temp > thr(2)) = thr(2);
        end
        % Normalize to the range [0, 1] and scale to uint16
        temp = (temp - min(temp, [], 'all')) ./ range(temp, 'all');
        out{i} = uint16(temp * 2^16); % Scale to 16-bit range
    end

    % Concatenate processed batches along the 3rd dimension
    out = cat(3, out{:});
end
end