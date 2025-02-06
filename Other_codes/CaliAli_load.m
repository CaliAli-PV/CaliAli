function data = CaliAli_load(filename, varname)
%% CaliAli_load: Load a specific variable or all variables from a .mat file.
%
% Inputs:
%   filename - String specifying the .mat file to load.
%   varname  - (Optional) Name of the variable to load. Supports dot notation
%              for nested structures (e.g., 'Struct.elem1'). If not provided,
%              all variables are loaded.
%
% Outputs:
%   data - Loaded variable or a structure containing all variables.
%
% Usage:
%   data = CaliAli_load('data.mat');              % Load all variables
%   var  = CaliAli_load('data.mat', 'varname');   % Load a specific variable
%   elem = CaliAli_load('data.mat', 'Struct.elem1'); % Load nested structure element
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025


if nargin == 0
    error('Filename is required.');
end

% Check if filename has .mat extension
if ~endsWith(filename(:)', '.mat')
    filename = [filename '.mat'];
end

if nargin == 1
    % Load all variables if varname is not provided
    data = load(filename);
else
    % Load the specific variable (including nested structures)
    try
        % Split the varname by dots to handle nested structures
        parts = strsplit(varname, '.');

        % Load the top-level structure
        data = load(filename, parts{1});
        data = data.(parts{1});

        % Access nested elements
        for i = 2:numel(parts)
            data = data.(parts{i});
        end
    catch
        error('Invalid variable name or structure path.');
    end
end
end