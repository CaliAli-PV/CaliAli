function data = CaliAli_load(filename, varname)
  % CaliAli_load loads a specific variable or all variables from a .mat file.
  % Supports loading nested structures using dot notation (e.g., 'Struct.elem1').
  %
  % Inputs:
  %   filename: Name of the .mat file.
  %   varname: (Optional) Name of the variable to load. Can include dot notation
  %            for nested structures. If not provided, all variables are loaded.
  %
  % Outputs:
  %   data: The loaded variable or a structure containing all variables.

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