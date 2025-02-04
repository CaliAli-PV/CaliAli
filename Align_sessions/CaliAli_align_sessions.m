function CaliAli_align_sessions(varargin)
% CALIALI_ALIGN_SESSIONS Aligns session data for the CaliAli analysis pipeline.
%   This function processes input files, performs inter-session alignment, 
%   calculates projections, and saves the transformed data.
%   
%   Usage:
%       CaliAli_align_sessions(CaliAli_options);
%       where CaliAli_options is a structure containing various settings
%       for alignment and processing.
%
%   The function includes the following steps:
%   1. Loads and processes the input files.
%   2. Detrends the data and calculates projections.
%   3. Performs session alignment by translating and shifting the sessions.
%   4. Evaluates the blood vessel (BV) similarity score and may switch to neuron-based alignment if necessary.
%   5. Saves the relevant variables and aligned session data.
%
%   Author: Pablo Vergara
%   Date:2025

% Process options and input parameters
CaliAli_options = CaliAli_parameters(varargin{:});

% Prompt user for input files if not provided
if isempty(CaliAli_options.inter_session_alignment.input_files)
    CaliAli_options.inter_session_alignment.input_files = uipickfiles('FilterSpec','*.mat');
end

% Detrend data and calculate projections
CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options);

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

% If final neuron alignment is enabled, apply additional shifts
if CaliAli_options.inter_session_alignment.final_neurons
    [P4, CaliAli_options] = sessions_non_rigid(P3, CaliAli_options, true);
    P = table(P1, P2, P3, P4, 'VariableNames', {'Original', 'Translations', 'CaliAli', 'CaliAli+neurons'});
else
    P = table(P1, P2, P3, 'VariableNames', {'Original', 'Translations', 'CaliAli'});
end

% Convert gray projections to RGB
P = BV_gray2RGB(P);

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

function [P, CaliAli_options] = evaluate_BV(P, CaliAli_options)
% EVALUATE_BV Evaluates the blood vessel similarity score and adjusts alignment accordingly.
%   This function calculates the BV similarity score, and if the score is below a certain threshold,
%   it switches to neuron-based alignment.

% Calculate BV similarity score
CaliAli_options.inter_session_alignment.BV_score = get_BV_NR_score(P, 2);

% Display BV similarity score
fprintf(1, 'Blood-vessel similarity score: %1.3f \n', CaliAli_options.inter_session_alignment.BV_score);

% If BV score is too low, switch to neuron-based alignment
if CaliAli_options.inter_session_alignment.BV_score < 2.7 && CaliAli_options.inter_session_alignment.Force_BV == 0
    fprintf(2, 'Blood-vessel similarity score is too low! \n Results may not be accurate! \n');
    fprintf(2, 'Aligning utilizing neurons data \n');
    
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
    P = BV_gray2RGB(P);
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
