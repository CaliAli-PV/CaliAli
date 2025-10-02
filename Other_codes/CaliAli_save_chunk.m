function CaliAli_save_chunk(out,fullFileName,F, Y,ix)
%% CaliAli_save_chunk: Save or append video data to a .mat file in chunks.
%
% Inputs:
%   filename - String specifying the file path to save or append data.
%   Y        - 3D array containing the video data to be stored.
%   Id       - Id of the sessions being saved
%
% Outputs:
%   None (data is saved to the specified file).
%
% Usage:
%   CaliAli_save_chunk('output.mat', Y);
%
% Notes:
%   - If the file exists, new data is appended along the third dimension.
%   - If the file does not exist, a new file is created with '-v7.3' format.
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
