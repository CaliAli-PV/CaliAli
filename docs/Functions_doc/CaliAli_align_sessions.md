### CaliAli_align_sessions {#CaliAli_align_sessions}

#### Syntax
```matlab
function CaliAli_align_sessions(varargin)
```
#### Description
This function processes input files, performs inter-session alignment, calculates projections, and saves the transformed data.

For a detailed walk-through of the preprocessing cache, projection calculation,
alignment stages, integrity checks, and saved outputs, see
[How `CaliAli_align_sessions` Works](CaliAli_align_sessions_how_it_works.md).

##### Function Inputs:
| Parameter Name | Type         | Description                                      |
|----------------|--------------|--------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md) | Structure    | Contains configuration options and transformation data.|

##### Function Outputs:
| Parameter Name | Type         | Description                                      |
|----------------|--------------|--------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md) | Structure    | Updated structure.
| video_aligned.mat | `.mat` file    | `.mat` file with the aligned video and other alignment outputs |

##### Example usage:
```matlab
CaliAli_options = CaliAli_demo_parameters();
CaliAli_align_sessions(CaliAli_options);
```


