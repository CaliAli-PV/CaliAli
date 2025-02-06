function CaliAli_save(filename, varargin)
%% CaliAli_save: Save or append variables to a MAT-file.
%
% Inputs:
%   filename - String specifying the file path to save or append data.
%   varargin - List of variables to be saved.
%
% Outputs:
%   None (data is saved to the specified file).
%
% Usage:
%   CaliAli_save('output.mat', var1, var2);
%
% Notes:
%   - If the file exists, variables are appended.
%   - If the file does not exist, a new file is created using '-v7.3' format.
%   - No compression is used to optimize read/write speed.
%   - Variable names are automatically extracted; if unavailable, a default name is assigned.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

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