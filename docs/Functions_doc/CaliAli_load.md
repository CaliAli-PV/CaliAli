
#### Syntax
```matlab
function data = CaliAli_load(filename, varname)
```

#### Description
CaliAli_load: Load a specific variable or all variables from a .mat file.

##### Function Inputs:
| Parameter Name | Type   | Description                                           |
|---------------|--------|-------------------------------------------------------|
| filename      | String | String specifying the .mat file to load.             |
| varname       | String | (Optional) Name of the variable to load. Supports dot notation for nested structures (e.g., 'Struct.elem1'). If not provided, all variables are loaded.|

##### Function Outputs:
| Parameter Name | Type  | Description                      |
|---------------|-------|----------------------------------|
| data          | Array | Loaded variable or a structure containing all variables.|

##### Example usage:
```matlab
data = CaliAli_load('data.mat');               % Load all variables
var  = CaliAli_load('data.mat', 'varname');    % Load a specific variable
elem = CaliAli_load('data.mat', 'Struct.elem1');  % Load nested structure element
```
