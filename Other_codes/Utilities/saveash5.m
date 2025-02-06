function saveash5(data, path_to_file,groupname)
% save the variable stored in data in a h5 file named path_to_file (includes the
% path to the directory). The file is saved with the same class as data.
% Set default values
if ~exist('path_to_file','var');path_to_file = 'data.h5';end
if ~exist('groupname','var');groupname = '/Object';end

data_type = class(data);
sizY = size(data);
sizY(end)=inf;
nd = numel(sizY)-1;

[fileExists,groupExists] = checkH5Group(path_to_file, groupname);

if ~groupExists
    h5create(path_to_file,groupname,sizY,'Datatype',data_type,'ChunkSize',[sizY(1:end-1),1]);
    start_point = ones(1,nd+1); 
else
    fprintf('Appending to existing file \n')
    info = h5info(path_to_file);
    strcmp({info.Datasets.Name},groupName(2:end))

    start_point = [ones(1,nd),info.Datasets.Dataspace.Size(end)+1];
end
  
h5write(path_to_file,groupname,data,start_point,size(data));

end

function [fileExists,groupExists] = checkH5Group(filename, groupName)
% Checks if an HDF5 file exists and if it contains a specific group.
%
% Inputs:
%   filename:  Name of the HDF5 file.
%   groupName: Name of the group to check for.
%
% Outputs:
%   groupExists: True if the file and group exist, false otherwise.

groupExists = false; % Default to false
fileExists=exist(filename, 'file') == 2;
if fileExists % Check if the file exists
    try
        info = h5info(filename); % Get file information
        groupNames = {info.Datasets.Name}; % Extract group names
        
        % Check if the specified group exists within the group names
        if any(strcmp(groupNames,groupName(2:end))) 
            groupExists = true;
        end
    catch
        % Handle potential errors in accessing HDF5 file
        fprintf('Error accessing HDF5 file: %s\n', filename);
    end
end
end