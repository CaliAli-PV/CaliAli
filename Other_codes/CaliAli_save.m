function CaliAli_save(filename_or_batch, varargin)
%% CaliAli_save: Save or append variables to a MAT-file.
%
% Inputs:
%   filename_or_batch - Either:
%                      - String specifying the file path to save or append data (original behavior)
%                      - Cell array {filename, session_id, start_frame, end_frame, output_filename} (batch behavior)
%   varargin          - List of variables to be saved.
%
% Outputs:
%   None (data is saved to the specified file).
%
% Usage:
%   CaliAli_save('output.mat', var1, var2);                    % Original behavior
%   CaliAli_save({fn, sid, start, end, out}, Y, CaliAli_options); % Batch behavior
%
% Notes:
%   - If the file exists, variables are appended.
%   - If the file does not exist, a new file is created using '-v7.3' format.
%   - No compression is used to optimize read/write speed.
%   - Variable names are automatically extracted; if unavailable, a default name is assigned.
%   - For batch mode, saves to pre-allocated file at correct frame location.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Handle batch input format
if iscell(filename_or_batch)
    % Batch format: {filename, session_id, start_frame, end_frame, output_filename}
    batch_info = filename_or_batch;
    input_filename = batch_info{1};
    session_id = batch_info{2};
    start_frame = batch_info{3};
    end_frame = batch_info{4};
    output_filename = batch_info{5};
    
    % For batch processing, save Y variable to pre-allocated file
    if nargin >= 2 && strcmp(inputname(2), 'Y')
        Y = varargin{1};
        
        % Write to the correct frame location in the pre-allocated file
        m = matfile(output_filename, 'Writable', true);
        
        % Calculate frame range in the output file
        % For now, assume sequential writing (could be improved with proper mapping)
        num_frames = end_frame - start_frame + 1;
        
        % Write the data to the correct location
        % Note: This assumes Y_empty was pre-allocated as 'Y' variable
        if isprop(m, 'Y_empty')
            % If pre-allocated with Y_empty, copy to correct location
            % This is a simplified approach - in practice you'd need proper frame mapping
            m.Y_empty(:, :, start_frame:end_frame) = Y;
        else
            % Direct write (assumes proper pre-allocation was done)
            try
                m.Y(:, :, start_frame:end_frame) = Y;
            catch
                % Fallback: create/append as new file
                fprintf('Warning: Could not write to pre-allocated location, creating new file section\n');
                Y_data.Y = Y;
                save(output_filename, '-struct', 'Y_data', '-v7.3', '-nocompression', '-append');
            end
        end
        
        fprintf('Saved batch frames %d-%d to %s\n', start_frame, end_frame, output_filename);
        return;
    else
        % For other variables in batch mode, use output filename
        filename = output_filename;
    end
else
    % Original format: string filename
    filename = filename_or_batch;
end

% Original behavior for non-batch or non-Y variables
% Create an empty structure
data = struct();

% Populate the structure with input variables
for i = 1:nargin - 1
    varName = inputname(i + 1);

    if isempty(varName)
        varName = ['var' num2str(i)];
    end

    data.(varName) = varargin{i};
end

if exist(filename, 'file')
    % File exists, append
    save(filename,'-nocompression','-struct', 'data', '-append');
else
    % File doesn't exist, create
    save(filename, '-v7.3', '-nocompression','-struct', 'data');
end

end