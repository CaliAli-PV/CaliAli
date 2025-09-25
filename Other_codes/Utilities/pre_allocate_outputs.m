function process_flags = pre_allocate_outputs(input_files,tag)
%% pre_allocate_outputs: Pre-allocate output files and determine processing flags.
%
% Inputs:
%   input_files - Cell array containing either:
%                 - Strings (original filenames) 
%                 - Cell arrays {filename, session_id, start_frame, end_frame, output_filename}
%
% Outputs:
%   process_flags - Logical array indicating which items need processing (true = process, false = skip)
%
% Usage:
%   process_flags = pre_allocate_outputs(opt.input_files);
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025

process_flags = false(1, length(input_files));
processed_outputs = {};  % Track which output files we've already handled

for k = 1:length(input_files)
    
    if ischar(input_files{k})
        % Original format - string filename
        filename = input_files{k};
        [filepath, name] = fileparts(filename);
          
        % Create an output file name by appending '_det' to the original file name
        if ~contains(name, tag)
            output_file = strcat(filepath, filesep, name, tag, '.mat');
        else
            output_file = strcat(filepath, filesep, name, '.mat');
        end
        
        
        % Check if output file already exists
        if ~isfile(output_file)
            process_flags(k) = true;
        else
            fprintf(1, 'File %s already exists!\n', output_file);
        end
        
    else
        % Batch format - cell array {filename, session_id, start_frame, end_frame, output_filename}
        batch_info = input_files{k};
        output_file = batch_info{5};
        
        % Check if we've already processed this output file
        if ~ismember(output_file, processed_outputs)
            processed_outputs{end+1} = output_file;
            
            if ~isfile(output_file)
                % Need to pre-allocate the output file
                fprintf(1, 'Pre-allocating output file: %s\n', output_file);
                
                % Get total dimensions by summing all batches for this output file
                total_frames = 0;
                d1 = 0; d2 = 0;
                
                for j = 1:length(input_files)
                    if iscell(input_files{j}) && strcmp(input_files{j}{5}, output_file)
                        % This batch belongs to the same output file
                        batch_frames = input_files{j}{4} - input_files{j}{3} + 1;
                        total_frames = total_frames + batch_frames;
                        
                        % Get dimensions from first batch
                        if d1 == 0
                            dims = get_data_dimension(input_files{j}{1});
                            d1 = dims(1);
                            d2 = dims(2);
                        end
                    end
                end
                
                % Pre-allocate the file
                if total_frames > 0
                    m = matfile(output_file, 'Writable', true);
                    m.Y(d1, d2, total_frames) = uint8(0);  % creates dataset on disk
                    fprintf(1, 'Pre-allocated file with dimensions [%d, %d, %d]\n', d1, d2, total_frames);
                end
                
                % Mark all batches for this output as needing processing
                for j = 1:length(input_files)
                    if iscell(input_files{j}) && strcmp(input_files{j}{5}, output_file)
                        process_flags(j) = true;
                    end
                end
                
            else
                fprintf(1, 'Batched output file %s already exists!\n', output_file);
                % Mark all batches for this output as NOT needing processing
                for j = 1:length(input_files)
                    if iscell(input_files{j}) && strcmp(input_files{j}{5}, output_file)
                        process_flags(j) = false;
                    end
                end
            end
        end
        % If we've already processed this output file, the flags are already set
    end
end

end