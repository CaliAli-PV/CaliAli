function CaliAli_options = match_video_size(CaliAli_options)
%% match_video_size: Ensure consistent video dimensions across sessions.
%
% This function aligns video dimensions across multiple sessions by cropping 
% borders to match a common mask. It ensures that session data is properly 
% aligned before performing inter-session alignment.
%
% Inputs:
%   CaliAli_options - Structure containing configuration options for alignment.
%                     The details of this structure can be found in 
%                     CaliAli_demo_parameters().
%
% Outputs:
%   CaliAli_options - Updated structure with matched video dimensions.
%
% Usage:
%   CaliAli_options = match_video_size(CaliAli_options);
%
% Steps:
%   1. Loads session data and retrieves frame information.
%   2. Creates and aligns masks for all sessions.
%   3. Ensures mask consistency across sessions.
%   4. If necessary, crops session data to match the common mask.
%   5. Updates and saves modified session data and projections.
%
% Notes:
%   - The function ensures that different sessions have the same spatial dimensions.
%   - Cropping is performed based on the combined mask of all sessions.
%   - If all session masks match in size, no modifications are made.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Loop through each session and load the necessary data (F and Cn projections)
for i = 1:size(CaliAli_options.inter_session_alignment.output_files, 2)
    fullFileName = CaliAli_options.inter_session_alignment.output_files{i};
    in=h5info(fullFileName);
    dim=in.Datasets.Dataspace.Size;
    % Load the frame data (F) and neuron projection (Cn) for each session
    F(i) = dim(3);    
    % Initialize masks for each session
    Mask{i} = ones(dim(1),dim(2));
end

% Combine all masks across sessions, ensuring they are aligned and centered
Mask_all = catpad_centered(3, Mask{:});

% Create a logical mask based on non-NaN values across all sessions
k = ~max(isnan(Mask_all), [], 3);

% Resize and reshape the combined mask to match video dimensions
[d1, d2] = size(k);
Mask_all = reshape(reshape(Mask_all, d1 * d2, []) .* k(:), d1, d2, []);

% Adjust each session's individual mask to the final mask size
for i = 1:size(Mask_all, 3)
    temp = Mask_all(:,:,i);
    [d1, d2] = size(Mask{i});
    Mask{i} = reshape(temp(~isnan(temp)), d1, d2);
end

% Replace old masks and store the updated masks and frame data in the options
CaliAli_options.inter_session_alignment.F = F;
CaliAli_options.inter_session_alignment.Mask = Mask;

% Update the options with the new mask and frame data
replace_in(CaliAli_options);

end


function replace_in(CaliAli_options)
% REPLACE_IN Replaces the video dimensions across sessions by cropping borders to match the mask.
%   This function reshapes the session data (video frames and projections) to ensure that the
%   video dimensions match by applying the mask and cropping borders accordingly.
%
%   Input:
%       CaliAli_options - A structure containing the configuration options and session data.
%
%   Output:
%       None - The function updates the session files and saves the changes.

% Get the mask for each session
Mask = CaliAli_options.inter_session_alignment.Mask;

% Are the sessions already the same shape? Compare the SIZE, not the element
% count: a 100x120 session and a 120x100 one have the same numel, so counting
% elements called them consistent and skipped the reconciliation entirely,
% leaving two sessions that cannot be concatenated.
if ~all(cellfun(@(x) isequal(size(x), size(Mask{1})), Mask))
    % If the masks are not consistent, reshape and crop the videos to match the mask
    theFiles = CaliAli_options.inter_session_alignment.output_files;
    fprintf(1, 'Matching video dimensions across sessions by cropping borders...\n');
    
    % How many frames to hold at once while rewriting. This stage used to load
    % the whole session with CaliAli_load(file,'Y'), which is the one place in
    % the pipeline that ignored batch_sz: a recording that every other stage
    % processed in chunks was loaded entire here, and on a long session that is
    % where the run ran out of memory.
    chunk = compute_auto_batch_size( ...
        CaliAli_options.inter_session_alignment.batch_sz, theFiles{1});

    % Loop through each session to adjust the video size and projections
    for i = progress(1:size(theFiles, 2))
        fullFileName = theFiles{i};
        [rows, cols] = mask_rectangle(Mask{i}, fullFileName);
        crop_video_in_place(fullFileName, rows, cols, chunk);

        % Crop the projections stored alongside the video, by the same rectangle
        opt_i = CaliAli_load(fullFileName, 'CaliAli_options');
        temp = opt_i.inter_session_alignment;

        for k = 1:size(temp.P, 2)
            % Indexed by rows and columns, with a trailing colon. The old code
            % flattened each projection and indexed it with a linear mask, which
            % silently reduced a projection with more than one plane -- the fused
            % RGB one -- to its first channel.
            temp.P.(k){1, 1} = temp.P.(k){1, 1}(rows, cols, :);
        end
        temp.Cn  = temp.Cn(rows, cols, :);
        temp.PNR = temp.PNR(rows, cols, :);

        opt_i.inter_session_alignment = temp;
        CaliAli_save(fullFileName, 'CaliAli_options', opt_i);
    end
else
    % If the masks are consistent, inform the user
    fprintf(1, 'Number of pixels in each session correctly match!\n');
end

end


function [rows, cols] = mask_rectangle(M, label)
%% The rows and columns a session keeps, from its mask.
%
% The mask is the part of this session that every other session also covers.
% Because every frame is a rectangle and catpad_centered centres them, that
% overlap is itself a rectangle, and the code that used to do this relied on
% that silently: it took the mask's elements in linear order and reshaped them
% to the row and column counts. If the mask were ever not a rectangle that
% reshape would produce a scrambled image rather than an error, so the
% assumption is checked here instead of assumed.
M = logical(M);
rows = find(any(M, 2));
cols = find(any(M, 1));
if ~all(all(M(rows, cols))) || nnz(M) ~= numel(rows)*numel(cols)
    error('CaliAli:matchVideoSize:notRectangular', ...
        ['The overlap between sessions is not a rectangle for %s. Cropping to it ' ...
         'would not give a video.'], label);
end
rows = rows(:)'; cols = cols(:)';
end


function crop_video_in_place(fullFileName, rows, cols, chunk)
%% Rewrite Y cropped to [rows, cols], a few frames at a time.
% Through a temporary file, because the frame size changes and a v7.3 dataset
% cannot be resized in place. The original is replaced only once the new file is
% complete, so an interrupted run leaves the input intact.
dims = get_data_dimension(fullFileName);
T = dims(3);
if isequal(rows, 1:dims(1)) && isequal(cols, 1:dims(2))
    return   % nothing to crop for this session
end
if chunk <= 0 || chunk > T
    chunk = T;
end

w = whos(matfile(fullFileName), 'Y');
cls = w.class;

[pth, nam, ext] = fileparts(fullFileName);
tmp = fullfile(pth, [nam '_resize_tmp' ext]);
if isfile(tmp), delete(tmp); end

mt = matfile(tmp, 'Writable', true);
mt.Y(numel(rows), numel(cols), T) = cast(0, cls);
for t1 = 1:chunk:T
    t2 = min(t1+chunk-1, T);
    Y = CaliAli_load(fullFileName, 'Y', [t1, t2]);
    mt.Y(:, :, t1:t2) = cast(Y(rows, cols, :), cls);
end
clear mt

% Carry the options across before the swap, so the new file is complete.
opt_i = CaliAli_load(fullFileName, 'CaliAli_options');
CaliAli_save(tmp, 'CaliAli_options', opt_i);

movefile(tmp, fullFileName, 'f');
end
