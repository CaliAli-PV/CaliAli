function CaliAli_save_chunk(out,fullFileName,F, Y,ix)
%% CaliAli_save_chunk: Save or append video data to a .mat file in chunks.
%
% Inputs:
%   out          - Path of the output .mat file.
%   fullFileName - Chunk descriptor {filename, session_id, start_frame,
%                  end_frame, output_filename}, as made by create_batch_list.
%   F            - Number of frames in each session.
%   Y            - 3D array with the video data of this chunk.
%   ix           - Index of the session the chunk belongs to.
%
% Outputs:
%   None (data is saved to the specified file).
%
% Usage:
%   CaliAli_save_chunk(out_file, batch_entry, F, Y, session_index);
%
% Notes:
%   - If the file exists, Y is written at the frames of its session: after
%     the frames of the sessions before it, from start_frame to end_frame.
%   - If the file does not exist, a new file is created with '-v7.3' format
%     holding Y.
%   - No compression is used to optimize read/write speed.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025
[d1,d2,~]=size(Y);
filename=out;
F=cumsum([0,F]);
expected_frames = fullFileName{4} - fullFileName{3} + 1;
if size(Y,3) ~= expected_frames
    warning('CaliAli:CaliAli_save_chunk:frameMismatch', ...
        'Chunk %d has %d frames but %d were expected.', ix, size(Y,3), expected_frames);
end
if exist(filename, 'file') == 2
    m = matfile(filename, 'Writable', true);
    fprintf('Appending frames "%d-%d"...\n', F(ix)+fullFileName{3},F(ix)+fullFileName{4});
    m.Y(1:d1,1:d2,F(ix)+fullFileName{3}:F(ix)+fullFileName{4}) = Y;
else
    fprintf('Creating "%s"...\n', filename);
    save(filename, 'Y', '-v7.3', '-nocompression');
end
end
