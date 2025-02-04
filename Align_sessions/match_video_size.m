function CaliAli_options = match_video_size(CaliAli_options)
% MATCH_VIDEO_SIZE Matches the video dimensions across sessions by cropping borders.
%   This function ensures that the video dimensions across different sessions are consistent.
%   It calculates a mask for each session, centers them, and matches the sizes across the sessions.
%
%   Input:
%       CaliAli_options - A structure containing the configuration options, including session files and existing data.
%
%   Output:
%       CaliAli_options - The updated structure with the mask and video dimensions matched across sessions.

% Loop through each session and load the necessary data (F and Cn projections)
for i = 1:size(CaliAli_options.inter_session_alignment.output_files, 2)
    fullFileName = CaliAli_options.inter_session_alignment.output_files{i};
    
    % Load the frame data (F) and neuron projection (Cn) for each session
    F(i) = CaliAli_load(fullFileName, 'CaliAli_options.inter_session_alignment.F');
    temp = CaliAli_load(fullFileName, 'CaliAli_options.inter_session_alignment.Cn');
    
    % Initialize masks for each session
    Mask{i} = ones(size(temp));
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

% Check if the masks are consistent across sessions
if ~all(cellfun(@(x) numel(x), Mask) == numel(Mask{1}))
    % If the masks are not consistent, reshape and crop the videos to match the mask
    theFiles = CaliAli_options.inter_session_alignment.output_files;
    fprintf(1, 'Matching video dimensions across sessions by cropping borders...\n');
    
    % Loop through each session to adjust the video size and projections
    for i = progress(1:size(theFiles, 2))
        fullFileName = theFiles{i};
        
        % Reshape the video data based on the current mask
        Y = CaliAli_load(fullFileName, 'Y');
        [d1, d2] = size(Mask{i});
        Y = reshape(Y, d1 * d2, []);
        
        % Create a logical mask for valid video pixels
        k1 = max(sum(Mask{i}, 1));
        k2 = max(sum(Mask{i}, 2));
        mask_in = logical(Mask{i}(:));
        Y = Y(mask_in, :);  % Apply the mask to the video data
        Y = reshape(Y, k1, k2, []);  % Reshape the video data to match the mask
        
        % Load the options for the current session
        CaliAli_options = CaliAli_load(fullFileName, 'CaliAli_options');
        temp = CaliAli_options.inter_session_alignment;
        
        % Reshape and crop the projections (P)
        for k = 1:size(temp.P, 2)
            t = reshape(temp.P.(k){1, 1}, d1 * d2, []);
            t = t(mask_in);
            temp.P.(k){1, 1} = reshape(t, k1, k2, []);
        end
        
        % Reshape the Cn and PNR projections to match the mask size
        t = reshape(temp.Cn, d1 * d2, []);
        t = t(mask_in, :);
        temp.Cn = reshape(t, k1, k2, []);
        
        t = reshape(temp.PNR, d1 * d2, []);
        t = t(mask_in, :);
        temp.PNR = reshape(t, k1, k2, []);
        
        % Save the updated variables
        CaliAli_save(fullFileName, Y);
        CaliAli_options.inter_session_alignment = temp;
        CaliAli_save(fullFileName, CaliAli_options);
    end
else
    % If the masks are consistent, inform the user
    fprintf(1, 'Number of pixels in each session correctly match!\n');
end

end
