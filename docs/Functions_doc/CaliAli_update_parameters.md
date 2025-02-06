```matlab
function CaliAli_update_parameters(varargin)
```

#### Description
CaliAli_update_parameters: Update parameters in multiple CaliAli session files.

##### Function Inputs:
| Parameter Name | Type    | Description                                      |
|---------------|---------|--------------------------------------------------|
| varargin      | cell    | Key-value pairs specifying parameter names and new values, or a structure array containing multiple parameters.|

##### Function Outputs:
None: Updates and saves modified parameters in selected .mat files. |

##### Example usage:
```matlab
CaliAli_update_parameters('sf', 15, 'detrend', 2);
CaliAli_update_parameters(CaliAli_options);
```
