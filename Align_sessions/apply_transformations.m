function CaliAli_options = apply_transformations(CaliAli_options)
%% apply_transformations: Apply translation and non-rigid shifts to session data.
%
% Inputs:
%   CaliAli_options - Structure containing configuration options and transformation data.
%                     Details can be found in CaliAli_demo_parameters().
%
% Outputs:
%   CaliAli_options - Updated structure with applied transformations.
%
% Usage:
%   CaliAli_options = apply_transformations(CaliAli_options);
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Normalize the range by dividing by the maximum range value
R = CaliAli_options.inter_session_alignment.range;
R = single(R ./ max(R));

flag_field = 'alignment_completed';
out_file = CaliAli_options.inter_session_alignment.out_aligned_sessions;
input_F = CaliAli_options.inter_session_alignment.input_F;
if isempty(input_F) && isfield(CaliAli_options.inter_session_alignment, 'F')
    input_F = CaliAli_options.inter_session_alignment.F;
end
session_labels = ensure_labels(CaliAli_options.inter_session_alignment, numel(input_F));
aligned_per_session = [];
expected_cumsum = [];
aligned_running_total = 0;

if isfile(out_file)
    try
        done_flag = CaliAli_load(out_file, flag_field);
    catch
        done_flag = false;
    end
    if ~done_flag
        warning('CaliAli:apply_transformations:incompleteFile', ...
            'Found incomplete aligned file. Recomputing...');
        delete(out_file);
    else
        fprintf(1, 'File with name "%s" already exists.\n', out_file);
        return
    end
end

% If the output file for aligned sessions does not exist, apply transformations
if ~isfile(out_file)

    CaliAli_save(out_file, flag_field, false);

    TheFiles = CaliAli_options.inter_session_alignment.input_files;
    for i=1:length(TheFiles)
        TheFiles{i}{1}=TheFiles{i}{5};
    end
    max_ses_ix = max(cellfun(@(f) f{2}, TheFiles));
    if numel(input_F) < max_ses_ix
        input_F(max_ses_ix) = 0;
        session_labels(max_ses_ix) = {''};
    end
    aligned_per_session = zeros(size(input_F));
    expected_cumsum = cumsum(input_F);

    % Loop through each output file and apply the transformations
    for k = 1:length(TheFiles)


        fullFileName = TheFiles{k}{1};
        fprintf(1, 'Processing batch from %s\n', fullFileName);
        ses_ix=TheFiles{k}{2};
   


        % Load the current session file
        fprintf(1, 'Applying shifts to %s\n', fullFileName);

        % Load data from the file
        Y = CaliAli_load(TheFiles{k}, 'Y');
        if CaliAli_options.inter_session_alignment.do_alignment_translation
            % Apply translations using the stored translation data (T)
            Y = apply_translations(Y, CaliAli_options.inter_session_alignment.T(ses_ix,:), CaliAli_options.inter_session_alignment.T_Mask);
        end

        if CaliAli_options.inter_session_alignment.do_alignment_non_rigid

            % Apply non-rigid shifts (NR shifts) using the stored shifts
            Y = apply_NR_shifts(Y, CaliAli_options.inter_session_alignment.shifts(:,:,:,ses_ix), CaliAli_options.inter_session_alignment.NR_Mask);
        end
            % If final neuron transformations are enabled, apply additional non-rigid shifts for neurons
        if CaliAli_options.inter_session_alignment.final_neurons
                Y = apply_NR_shifts(Y, CaliAli_options.inter_session_alignment.shifts_n(:,:,:,ses_ix), CaliAli_options.inter_session_alignment.NR_Mask_n);
        end
       

        frames_this_chunk = size(Y, 3);
        aligned_per_session(ses_ix) = aligned_per_session(ses_ix) + frames_this_chunk;
        aligned_running_total = aligned_running_total + frames_this_chunk;
        if aligned_per_session(ses_ix) > input_F(ses_ix)
            report_frame_issue(session_labels{ses_ix}, 'apply_transformations concatenation', input_F(ses_ix), aligned_per_session(ses_ix));
        end
        if aligned_per_session(ses_ix) == input_F(ses_ix)
            expected_running_total = expected_cumsum(ses_ix);
            if aligned_running_total ~= expected_running_total
                report_frame_issue(session_labels{ses_ix}, 'apply_transformations cumulative check', expected_running_total, aligned_running_total);
            end
        end

        % Save the transformed data to the output file
        CaliAli_save_chunk(out_file, ...
            TheFiles{k},CaliAli_options.inter_session_alignment.F,Y,ses_ix);
    end
    for ses_ix = 1:numel(input_F)
        if aligned_per_session(ses_ix) ~= input_F(ses_ix)
            report_frame_issue(session_labels{ses_ix}, 'apply_transformations final per-session check', input_F(ses_ix), aligned_per_session(ses_ix));
        end
    end
    try
        m_status = matfile(out_file);
        info = whos(m_status, 'Y');
        expected_frames = sum(input_F);
        if isempty(info) || numel(info.size) < 3
            actual_frames = 0;
        else
            actual_frames = info.size(3);
        end
        if actual_frames ~= expected_frames
            report_frame_issue(out_file, 'aligned output verification', expected_frames, actual_frames);
        else
            CaliAli_save(out_file, flag_field, true);
        end
    catch ME
        warning('CaliAli:apply_transformations:flagUpdate', 'Unable to verify aligned stack: %s', ME.message);
    end
else
    % If the output file already exists, inform the user
    fprintf(1, 'File with name "%s" already exists.\n', out_file);
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

function labels = ensure_labels(opt, n_sessions)
if isfield(opt, 'input_file_labels') && ~isempty(opt.input_file_labels)
    labels = opt.input_file_labels;
    if numel(labels) < n_sessions
        labels(end+1:n_sessions) = {''};
    end
else
    labels = repmat({''}, n_sessions, 1);
end
end

function report_frame_issue(session_label, stage_label, expected, actual)
if isempty(session_label)
    session_label = 'Unknown session';
end
if exist('cprintf', 'file')
    cprintf('_red', 'Frame count mismatch for %s during %s: expected %g, found %g.\n', ...
        session_label, stage_label, expected, actual);
else
    fprintf(2, 'Frame count mismatch for %s during %s: expected %g, found %g.\n', ...
        session_label, stage_label, expected, actual);
end
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
