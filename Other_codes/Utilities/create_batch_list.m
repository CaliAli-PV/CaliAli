function [modified_input_files,F] = create_batch_list(input_files, batch_sz,tag)
%% create_batch_list: Create batch-aware input file list for processing.
%
% Inputs:
%   input_files - Cell array of file paths to process
%   batch_sz    - Maximum number of frames per batch (0 = no batching)
%
% Outputs:
%   modified_input_files - Cell array where each element is either:
%                         - String (original filename) if no batching needed
%                         - Cell array {filename, session_id, start_frame, end_frame, output_filename} if batching
%
% Usage:
%   opt.input_files = create_batch_list(opt.input_files, 3000);
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

modified_input_files = {};
batch_idx = 1;

for session_id = 1:length(input_files)
    filename = input_files{session_id};

    % Get file dimensions efficiently
    dims = get_data_dimension(filename);
    total_frames = dims(3);
    F(session_id)=total_frames;

    % Generate output filename (preserve original naming scheme)
    [filepath, name, ext] = fileparts(filename);


    % Create an output file name by appending '_det' to the original file name
    if ~contains(name, tag)
        output_filename = strcat(filepath, filesep, name, tag, ext);
    else
        output_filename = strcat(filepath, filesep, name, ext);
    end


    if batch_sz <= 0 || total_frames <= batch_sz
        % No batching needed - return original filename as string
        num_chunks=1;
    else
        num_chunks = ceil(total_frames / batch_sz);
    end
    % Split into balanced chunks - return as cell arrays

    chunk_size = ceil(total_frames / num_chunks);

    for chunk = 1:num_chunks
        start_frame = (chunk - 1) * chunk_size + 1;
        end_frame = min(chunk * chunk_size, total_frames);

        modified_input_files{batch_idx} = {filename, session_id, start_frame, end_frame, output_filename};
        batch_idx = batch_idx + 1;
    end

end

end