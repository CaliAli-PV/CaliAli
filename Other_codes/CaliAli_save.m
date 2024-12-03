function CaliAli_save(filename, varargin)
% Saves variables to a MAT-file, appending if the file exists,
% or creating it if it doesn't. Uses -v7.3 and -nocompression.

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