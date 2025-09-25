function batch_list = create_batch_list(input_files, batch_sz)
%% create_batch_list: Create batch processing list for chunked video processing.
%
% Inputs:
%   input_files - Cell array of file paths to process
%   batch_sz    - Maximum number of frames per batch (0 = no batching)
%
% Outputs:
%   batch_list  - Cell array with columns: {filename, session_id, start_frame, end_frame}
%
% Usage:
%   batch_list = create_batch_list({'file1.mat', 'file2.mat'}, 3000);
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025

batch_list = {};
batch_idx = 1;

for session_id = 1:length(input_files)
    filename = input_files{session_id};
    
    % Get file dimensions efficiently
    dims = get_data_dimension(filename);
    total_frames = dims(3);
    
    if batch_sz <= 0 || total_frames <= batch_sz
        % No batching needed - process entire file
        batch_list{batch_idx, 1} = filename;
        batch_list{batch_idx, 2} = session_id;
        batch_list{batch_idx, 3} = 1;
        batch_list{batch_idx, 4} = total_frames;
        batch_idx = batch_idx + 1;
    else
        % Split into balanced chunks
        num_chunks = ceil(total_frames / batch_sz);
        chunk_size = ceil(total_frames / num_chunks);
        
        for chunk = 1:num_chunks
            start_frame = (chunk - 1) * chunk_size + 1;
            end_frame = min(chunk * chunk_size, total_frames);
            
            batch_list{batch_idx, 1} = filename;
            batch_list{batch_idx, 2} = session_id;  
            batch_list{batch_idx, 3} = start_frame;
            batch_list{batch_idx, 4} = end_frame;
            batch_idx = batch_idx + 1;
        end
    end
end

end