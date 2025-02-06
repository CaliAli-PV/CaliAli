function CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options)
%% detrend_batch_and_calculate_projections: Perform detrending and projection calculations for batch processing.
%
% This function processes a batch of input files by applying detrending, 
% calculating projections, and saving the transformed data. It updates the 
% CaliAli_options structure with the computed results.
%
% Inputs:
%   CaliAli_options - Structure containing configuration options for the alignment process.
%                     The details of this structure can be found in 
%                     CaliAli_demo_parameters().
%
% Outputs:
%   CaliAli_options - Updated structure with calculated projections and other results.
%
% Usage:
%   CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options);
%
% Steps:
%   1. Loads input files and checks for existing processed files.
%   2. Applies detrending and calculates projections if not already done.
%   3. Computes key features such as maximum projections, PNR, and correlation images.
%   4. Saves the detrended data and calculated projections for further alignment.
%
% Notes:
%   - If projections and detrending have already been performed for a file, 
%     the function skips redundant processing.
%   - Detrended data is stored in separate output files with the suffix '_det.mat'.
%   - The function supports batch processing of multiple input files.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Extract the options related to inter-session alignment
opt = CaliAli_options.inter_session_alignment;

% If no input files are specified, prompt the user to select input files
if isempty(opt.input_files)
    opt.input_files = uipickfiles('FilterSpec','*.mat');
end

% Initialize the options structure for further use
opt_g = opt;

% Loop over each input file
for k = 1:length(opt_g.input_files)
    % Get the full file name and separate the file path and name
    fullFileName = opt_g.input_files{k};
    [filepath, name] = fileparts(fullFileName);
    
    % Create an output file name by appending '_det' to the original file name
    if ~contains(name, {'det', 'aligned'})
        out{k} = strcat(filepath, filesep, name, '_det', '.mat');
    else
        out{k} = strcat(filepath, filesep, name, '.mat');
    end
    
    % If the output file does not exist, perform detrending and projection calculation
    if ~isfile(out{k})
        fprintf(1, 'Detrending and calculating relevant projections for %s\n', fullFileName);
        
        % Load the data from the input file
        Y = CaliAli_load(fullFileName, 'Y');
        
        % Detrend the data and calculate projections
        [Y, P, R(k), opt] = get_projections_and_detrend(Y, opt_g); %#ok
        
        % Save the detrended data to the output file
        CaliAli_save(out{k}(:), Y);
        
        % Update the options with the range of the projections
        opt.range = R(k);
        
        % Calculate the size of the data (number of frames)
        F = size(Y, 3);
        F_all(k) = F; %#ok
        
        % Calculate the maximum projections and scale them
        Cn = max(P.(3){1, 1}, [], 3);
        opt.Cn_scale = max(Cn, [], 'all');
        opt.Cn = Cn ./ opt.Cn_scale;
        
        % Calculate the non-rigid projections (PNR)
        opt.PNR = max(P.PNR{1, 1}, [], 3);
        
        % Store the number of frames and projections in the options
        opt.F = F;
        opt.P = P;
        
        % Update the CaliAli_options structure with the modified options
        CaliAli_options.inter_session_alignment = opt;
        
        % Save the updated options to the output file
        CaliAli_save(out{k}(:), CaliAli_options);
    else
        % If the output file already exists, load the pre-calculated options
        temp = CaliAli_load(out{k}, 'CaliAli_options.inter_session_alignment');
        R(k) = temp.range; %#ok
        F_all(k) = temp.F; %#ok
        
        % Inform the user that the calculation has already been done for this file
        fprintf(1, 'Calculation of projections and detrending is already done for file "%s".\n', fullFileName);
    end
end

% Restore the original options and update the output file list and other fields
opt = opt_g;
opt.output_files = out;
opt.range = R;
opt.F = F_all;

% Update the CaliAli_options structure with the final options
CaliAli_options.inter_session_alignment = opt;

end
