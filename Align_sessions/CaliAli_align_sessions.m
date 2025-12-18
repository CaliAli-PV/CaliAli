function CaliAli_options = CaliAli_align_sessions(varargin)
%% CaliAli_align_sessions: Perform inter-session alignment for CaliAli analysis.
%
% This function processes input files, performs inter-session alignment, 
% calculates projections, and saves the transformed data.
%
% Inputs:
%   varargin - Variable input arguments, which are parsed into CaliAli_options.
%              The details of the CaliAli_options structure can be found in 
%              CaliAli_demo_parameters().
%
% Outputs:
%   None (aligned session data is saved to disk).
%
% Usage:
%   %   CaliAli_align_sessions(CaliAli_options);  % Using predefined options
%
% Steps:
%   1. Loads and processes the input files.
%   2. Detrends the data and calculates projections.
%   3. Performs session alignment by translating and shifting the sessions.
%   4. Evaluates blood vessel (BV) similarity and switches to neuron-based 
%      alignment if necessary.
%   5. Saves the relevant variables and aligned session data.
%
% Notes:
%   - The function supports both rigid and non-rigid alignment.
%   - If blood vessel alignment is not reliable, neuron-based alignment is used.
%   - Alignment metrics and final transformations are saved for further analysis.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025


% Process options and input parameters
CaliAli_options = CaliAli_parameters(varargin{:});

% Prompt user for input files if not provided
if isempty(CaliAli_options.inter_session_alignment.input_files)
    CaliAli_options.inter_session_alignment.input_files = uipickfiles('FilterSpec','*.mat');
end

% Record input frame counts prior to detrending for later verification
CaliAli_options = record_input_frame_counts(CaliAli_options);

% Detrend data and calculate projections
CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options);

% Verify detrended outputs match the original frame counts
CaliAli_options = verify_detrended_outputs(CaliAli_options);

% Set the output file name for aligned sessions
CaliAli_options.inter_session_alignment.out_aligned_sessions = ...
    [CaliAli_options.inter_session_alignment.output_files{end}(1:end-7), 'Aligned.mat'];

% Match video size if necessary
CaliAli_options = match_video_size(CaliAli_options);

% Get stored projections
P1 = get_stored_projections(CaliAli_options);


% Perform translation and non rigid session registration
[P2, CaliAli_options] = sessions_translate(P1, CaliAli_options);
[P3, CaliAli_options] = sessions_non_rigid(P2, CaliAli_options);

% If final neuron alignment is enabled, apply additional non rigid
% registration utilizing only neurons data.
ses_id=CaliAli_options.inter_session_alignment.same_ses_id;
if CaliAli_options.inter_session_alignment.final_neurons
    [P4, CaliAli_options] = sessions_non_rigid(P3, CaliAli_options, true);
    P = table(P1, P2, P3, P4, 'VariableNames', {'Original', 'Translations', 'CaliAli', 'CaliAli+neurons'});
else
    P = table(P1, P2, P3, 'VariableNames', {'Original', 'Translations', 'CaliAli'});
end

% Convert gray projections to RGB
P = BV_gray2RGB(P,ses_id);

% If projection type is 'BV', evaluate blood vessel similarity
if contains(CaliAli_options.inter_session_alignment.projections, 'BV')
    [P, CaliAli_options] = evaluate_BV(P, CaliAli_options);
end

% Store final projections and calculate alignment metrics
CaliAli_options.inter_session_alignment.P = P;
CaliAli_options.inter_session_alignment.alignment_metrics = get_alignment_metrics(P);

% Apply final transformations to the data
CaliAli_options = apply_transformations(CaliAli_options);

% Save the relevant variables
save_relevant_variables(CaliAli_options);

end

function CaliAli_options = record_input_frame_counts(CaliAli_options)
files = CaliAli_options.inter_session_alignment.input_files;
if isempty(files)
    CaliAli_options.inter_session_alignment.input_F = [];
    CaliAli_options.inter_session_alignment.input_file_labels = {};
    return
end
num_sessions = max(cellfun(@(idx) resolve_session_id(files{idx}, idx), num2cell(1:numel(files))));
input_F = zeros(num_sessions, 1);
labels = cell(num_sessions, 1);

for k = 1:numel(files)
    session_id = resolve_session_id(files{k}, k);
    src_file = resolve_source_file(files{k});
    try
        dims = get_data_dimension(src_file);
        input_F(session_id) = dims(3);
        if isempty(labels{session_id})
            labels{session_id} = src_file;
        end
        [isZero, errMsg] = last_frame_is_zero(src_file);
        if isZero
            report_frame_issue(labels{session_id}, 'input last frame check', dims(3), 0, errMsg);
            error('CaliAli:frameCheck', 'Last frame of %s is all zeros.', src_file);
        end
    catch ME
        report_frame_issue(src_file, 'input frame count (pre-detrend)', NaN, NaN, ME.message);
    end
end

CaliAli_options.inter_session_alignment.input_F = input_F;
CaliAli_options.inter_session_alignment.input_file_labels = labels;
end

function CaliAli_options = verify_detrended_outputs(CaliAli_options)
input_F = CaliAli_options.inter_session_alignment.input_F;
labels = ensure_labels(CaliAli_options.inter_session_alignment);
det_files = CaliAli_options.inter_session_alignment.output_files;
det_F = zeros(numel(input_F), 1);

if numel(det_files) ~= numel(input_F)
    report_frame_issue('All sessions', 'detrend_batch_and_calculate_projections (file count mismatch)', numel(input_F), numel(det_files));
end

for k = 1:min(numel(det_files), numel(input_F))
    det_file = det_files{k};
    actual_frames = safe_count_frames(det_file);
    det_F(k) = actual_frames;
    if input_F(k) ~= actual_frames
        report_frame_issue(labels{k}, 'detrend_batch_and_calculate_projections', input_F(k), actual_frames);
    end
    [isZero, errMsg] = last_frame_is_zero(det_file);
    if isZero
        report_frame_issue(labels{k}, 'detrend_batch_and_calculate_projections last frame check', actual_frames, 0, errMsg);
        error('CaliAli:frameCheck', 'Last frame of %s is all zeros.', det_file);
    end
end

CaliAli_options.inter_session_alignment.detrend_F = det_F;
end

function session_id = resolve_session_id(entry, default_id)
if iscell(entry) && numel(entry) >= 2 && isnumeric(entry{2})
    session_id = entry{2};
else
    session_id = default_id;
end
end

function src_file = resolve_source_file(entry)
if iscell(entry)
    src_file = entry{1};
else
    src_file = entry;
end
end

function labels = ensure_labels(opt)
if isfield(opt, 'input_file_labels') && ~isempty(opt.input_file_labels)
    labels = opt.input_file_labels;
else
    labels = repmat({''}, numel(opt.input_F), 1);
end
end

function n_frames = safe_count_frames(path)
n_frames = 0;
try
    m = matfile(path);
    info = whos(m, 'Y');
    if isempty(info) || numel(info.size) < 3
        n_frames = 0;
    else
        n_frames = info.size(3);
    end
catch
    n_frames = 0;
end
end

function [isZero, errMsg] = last_frame_is_zero(path)
isZero = false;
errMsg = '';
try
    m = matfile(path);
    info = whos(m, 'Y');
    if isempty(info) || numel(info.size) < 3
        isZero = true;
        errMsg = 'Y is missing or empty';
        return
    end
    lastFrameIdx = info.size(3);
    if lastFrameIdx < 1
        isZero = true;
        errMsg = 'Y has no frames';
        return
    end
    lastFrame = m.Y(:, :, lastFrameIdx);
    isZero = ~any(lastFrame(:));
    if isZero
        errMsg = 'last frame is all zeros';
    end
catch ME
    isZero = true;
    errMsg = ME.message;
end
end

function report_frame_issue(session_label, stage_label, expected, actual, errMsg)
if nargin < 5
    errMsg = '';
end
if isempty(session_label)
    session_label = 'Unknown session';
end
if exist('cprintf', 'file')
    cprintf('_red', 'Frame count mismatch for %s during %s: expected %g, found %g. %s\n', ...
        session_label, stage_label, expected, actual, errMsg);
else
    fprintf(2, 'Frame count mismatch for %s during %s: expected %g, found %g. %s\n', ...
        session_label, stage_label, expected, actual, errMsg);
end
end

function [P, CaliAli_options] = evaluate_BV(P, CaliAli_options)
% EVALUATE_BV Evaluates the blood vessel similarity score and adjusts alignment accordingly.
%   This function calculates the BV similarity score, and if the score is below a certain threshold,
%   it switches to neuron-based alignment.

% Calculate BV similarity score
CaliAli_options.inter_session_alignment.BV_score = get_BV_NR_score(P, 2);

% Display BV similarity score
cprintf('-comment', 'Blood-vessel similarity score: %1.3f \n', CaliAli_options.inter_session_alignment.BV_score);

% If BV score is too low, switch to neuron-based alignment
if CaliAli_options.inter_session_alignment.BV_score < 2.7 && CaliAli_options.inter_session_alignment.Force_BV == 0
    cprintf('*red', 'Blood-vessel similarity score is too low! \n Results may not be accurate! \n');
    cprintf('blue', 'Aligning utilizing neurons data \n');
    
    % Switch to neuron-based projection for alignment
    CaliAli_options.inter_session_alignment.projections = 'Neuron';
    P1 = P.(1)(1, :);
    [P2, CaliAli_options] = sessions_translate(P1, CaliAli_options);
    
    % Perform non-rigid alignment
    fprintf(1, 'Calculating non-rigid alignments...\n');
    [P3, CaliAli_options] = sessions_non_rigid(P2, CaliAli_options);
    
    % If final neuron alignment is enabled, apply additional shifts
    if CaliAli_options.inter_session_alignment.final_neurons
        [P4, CaliAli_options] = sessions_non_rigid(P3, CaliAli_options, true);
        P = table(P1, P2, P3, P4, 'VariableNames', {'Original', 'Translations', 'CaliAli', 'CaliAli+neurons'});
    else
        P = table(P1, P2, P3, 'VariableNames', {'Original', 'Translations', 'CaliAli'});
    end
    
    % Convert gray projections to RGB
    P = BV_gray2RGB(P,CaliAli_options.inter_session_alignment.same_ses_id);
end

% Calculate neuron projection correlations
get_neuron_projections_correlations(P, 3);

end

function save_relevant_variables(CaliAli_options)
% SAVE_RELEVANT_VARIABLES Saves relevant variables after the alignment process.
%   This function saves the final projections and aligned session data to the specified output path.

% Extract the final projections
P = CaliAli_options.inter_session_alignment.P;

% Calculate the maximum projections and scale them
CaliAli_options.inter_session_alignment.Cn = max(P.(size(P, 2))(1, :).(3){1, 1}, [], 3);
CaliAli_options.inter_session_alignment.Cn_scale = max(CaliAli_options.inter_session_alignment.Cn, [], 'all');
CaliAli_options.inter_session_alignment.Cn = CaliAli_options.inter_session_alignment.Cn ./ CaliAli_options.inter_session_alignment.Cn_scale;

% Calculate non-rigid alignment projections
CaliAli_options.inter_session_alignment.PNR = max(P.(size(P, 2))(1, :).(4){1, 1}, [], 3);

% Save the data
CaliAli_save(CaliAli_options.inter_session_alignment.out_aligned_sessions(:), CaliAli_options);

end
