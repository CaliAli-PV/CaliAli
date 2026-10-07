### CaliAli_load {#CaliAli_load}

#### Syntax
```matlab
function data = CaliAli_load(filename_or_batch, varname, frame_range)
```

#### Description
CaliAli_load: Load a specific variable or all variables from a .mat file.

##### Function Inputs:
| Parameter Name | Type   | Description                                           |
|---------------|--------|-------------------------------------------------------|
| filename_or_batch | String or cell array | The .mat file to load, or a chunk descriptor `{filename, session_id, start_frame, end_frame, output_filename}` from [create_batch_list](create_batch_list.md#create_batch_list). With a chunk descriptor and `varname = 'Y'`, only that chunk's frames are loaded. |
| varname       | String | (Optional) Name of the variable to load. Supports dot notation for nested structures (e.g., 'Struct.elem1'). If not provided, all variables are loaded.|
| frame_range   | Vector | (Optional) `[start_frame, end_frame]` to load only those frames. Applies to `Y` only. |

##### Function Outputs:
| Parameter Name | Type  | Description                      |
|---------------|-------|----------------------------------|
| data          | Array | Loaded variable or a structure containing all variables.|

##### Example usage:
```matlab
data = CaliAli_load('data.mat');               % Load all variables
var  = CaliAli_load('data.mat', 'varname');    % Load a specific variable
elem = CaliAli_load('data.mat', 'Struct.elem1');  % Load nested structure element
Y    = CaliAli_load('data.mat', 'Y', [1, 1000]);  % Load frames 1-1000 of Y
Y    = CaliAli_load(batches{k}, 'Y');             % Load one chunk from create_batch_list
```
