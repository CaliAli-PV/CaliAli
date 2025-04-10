function CaliAli_save_chunk(CaliAli_options, Y,Id)
%% CaliAli_save_chunk: Save or append video data to a .mat file in chunks.
%
% Inputs:
%   filename - String specifying the file path to save or append data.
%   Y        - 3D array containing the video data to be stored.
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
F=[0,CaliAli_options.inter_session_alignment.F];
F=cumsum(F);
[d1,d2,~]=size(Y);
filename=CaliAli_options.inter_session_alignment.out_aligned_sessions;

if exist(filename, 'file') == 2
    m = matfile(filename, 'Writable', true);
    fprintf('Appending to "%s"...\n', filename);
    m.Y(1:d1,1:d2,F(Id)+1:F(Id+1)) = Y;
else
    fprintf('Creating "%s"...\n', filename);
    save(filename, 'Y', '-v7.3', '-nocompression');
end
end