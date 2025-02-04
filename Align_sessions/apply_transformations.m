function CaliAli_options = apply_transformations(CaliAli_options)
% APPLY_TRANSFORMATIONS Applies translation and non-rigid shifts to session data.
%   This function performs transformations such as translations and non-rigid shifts 
%   to session data (Y) based on the stored transformations (T, shifts, etc.) in the 
%   CaliAli_options structure. The results are saved to the specified output file.
%
%   Input:
%       CaliAli_options - A structure containing configuration options and transformation data.
%   
%   Output:
%       CaliAli_options - The updated structure with applied transformations.

% Normalize the range by dividing by the maximum range value
R = CaliAli_options.inter_session_alignment.range;
R = single(R ./ max(R));

% If the output file for aligned sessions does not exist, apply transformations
if ~isfile(CaliAli_options.inter_session_alignment.out_aligned_sessions)
    % Loop through each output file and apply the transformations
    for k = 1:length(CaliAli_options.inter_session_alignment.output_files)
        % Load the current session file
        fullFileName = CaliAli_options.inter_session_alignment.output_files{k};
        fprintf(1, 'Applying shifts to %s\n', fullFileName);
        
        % Load data from the file
        Y = CaliAli_load(fullFileName, 'Y');
        
        % Apply translations using the stored translation data (T)
        Y = apply_translations(Y, CaliAli_options.inter_session_alignment.T(k,:), CaliAli_options.inter_session_alignment.T_Mask);
        
        % Apply non-rigid shifts (NR shifts) using the stored shifts
        Y = apply_NR_shifts(Y, CaliAli_options.inter_session_alignment.shifts(:,:,:,k), CaliAli_options.inter_session_alignment.NR_Mask);
        
        % If final neuron transformations are enabled, apply additional non-rigid shifts for neurons
        if CaliAli_options.inter_session_alignment.final_neurons
            Y = apply_NR_shifts(Y, CaliAli_options.inter_session_alignment.shifts_n(:,:,:,k), CaliAli_options.inter_session_alignment.NR_Mask_n);
        end
        
        % Scale the data based on the range (R)
        if isa(Y, 'uint16')
            Y = uint16(single(Y) .* R(k));  % For uint16, scale the data
        else
            Y = uint8(single(Y) .* R(k));   % For uint8, scale the data
        end
        
        % Save the transformed data to the output file
        CaliAli_save_chunk(CaliAli_options.inter_session_alignment.out_aligned_sessions, Y);
    end
else
    % If the output file already exists, inform the user
    fprintf(1, 'File with name "%s" already exists.\n', CaliAli_options.inter_session_alignment.out_aligned_sessions);
end

end

function Vid = apply_translations(Vid, T, Mask)
% APPLY_TRANSLATIONS Applies translations to the video data.
%   This function translates the video data (Vid) based on the translation matrix T 
%   and the mask provided (Mask). The resulting video is returned after translation.
%
%   Input:
%       Vid  - The video data to be translated.
%       T    - The translation matrix to apply.
%       Mask - A mask indicating the valid regions in the video.
%
%   Output:
%       Vid  - The translated video data.

% Get the dimensions of the mask
[d1, d2, ~] = size(Mask);

% Find the maximum sum of the mask along each dimension (for reshaping)
f1 = max(sum(Mask, 1));
f2 = max(sum(Mask, 2));

% Apply the translation using imtranslate
Vid = imtranslate(Vid, T);

% Reshape the video data for applying the mask
Vid = reshape(Vid, d1 * d2, []);
Vid = Vid(logical(Mask), :);  % Keep only the valid mask regions

% Reshape the video data back to its original dimensions
Vid = reshape(Vid, f1, f2, []);
end

function Vid = apply_NR_shifts(Vid, S, Mask)
% APPLY_NR_SHIFTS Applies non-rigid shifts to the video data.
%   This function applies non-rigid shifts (S) to the video data (Vid) using imwarp.
%   The mask (Mask) is used to identify valid regions for the transformation.
%
%   Input:
%       Vid  - The video data to be transformed.
%       S    - The non-rigid shift data.
%       Mask - A mask indicating the valid regions in the video.
%
%   Output:
%       Vid  - The video data after applying the non-rigid shifts.

% Loop through each frame of the video and apply the non-rigid shift
parfor i = 1:size(Vid, 3)
    Vid(:,:,i) = imwarp(Vid(:,:,i) + 1, S, 'FillValues', 1);  % Apply the shift to each frame
end

% Find the maximum sum of the mask along each dimension (for reshaping)
f1 = max(sum(Mask, 1));
f2 = max(sum(Mask, 2));

% Reshape the video data to apply the mask
Vid = reshape(Vid, size(Vid, 1) * size(Vid, 2), []);
Vid(~Mask(:), :) = [];  % Remove areas outside the mask

% Reshape the video data back to its original dimensions
Vid = reshape(Vid, f1, f2, []);
end
