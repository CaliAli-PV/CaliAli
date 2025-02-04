function CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options)
% DETREND_BATCH_AND_CALCULATE_PROJECTIONS Detrends and calculates projections for a batch of input files.
%   This function loads input files, detrends the data, calculates projections, and saves the results.
%   It also updates the relevant fields in the CaliAli_options structure with the calculated results.
%
%   Input:
%       CaliAli_options - A structure containing configuration options for the alignment process.
%   
%   Output:
%       CaliAli_options - The updated structure with the calculated projections and other results.

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
