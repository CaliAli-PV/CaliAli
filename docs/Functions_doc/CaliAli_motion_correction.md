### CaliAli_motion_correction {#CaliAli_motion_correction}

```matlab
function CaliAli_options = CaliAli_motion_correction(varargin)
```

#### Description
CaliAli_motion_correction: Perform rigid and non-rigid motion correction on video files.

This function applies motion correction to a set of input video files. It performs both
rigid and non-rigid motion correction, interpolates dropped frames, squares borders, and
saves the corrected video as a .mat file.

##### Function Inputs:
| Parameter Name | Type | Description |
|---------------|------|-------------|
| varargin | Variable-length input argument list | Variable input arguments, which are parsed into  [CaliAli_options](CaliAli_parameters.md). |

##### Function Outputs:
| Parameter Name | Type | Description |
|---------------|------|-------------|
|  [CaliAli_options](CaliAli_parameters.md) | Updated structure containing the motion correction parameters. | - |

##### Example usage:
```matlab
CaliAli_options = CaliAli_motion_correction();   % Interactive file selection
CaliAli_options = CaliAli_motion_correction(CaliAli_options);   % Using predefined options
```
