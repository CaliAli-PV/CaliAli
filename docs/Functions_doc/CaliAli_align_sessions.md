### CaliAli_align_sessions {#CaliAli_align_sessions}

#### Syntax
```matlab
function CaliAli_options = CaliAli_align_sessions(varargin)
```
#### Description
This function processes input files, performs inter-session alignment, calculates projections, and saves the transformed data.

##### Function Inputs:
| Parameter Name | Type         | Description                                      |
|----------------|--------------|--------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md) | Structure    | Contains configuration options and transformation data.|

##### Function Outputs:
| Parameter Name | Type         | Description                                      |
|----------------|--------------|--------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md) | Structure    | Updated structure. The path of the aligned file is in `CaliAli_options.inter_session_alignment.out_aligned_sessions`. |
| `<last session>_Aligned.mat` | `.mat` file    | Aligned and concatenated video with the alignment outputs, saved next to the last session and named after it (e.g. `day15_ds_mc_Aligned.mat`). |

##### Example usage:
```matlab
CaliAli_options = CaliAli_demo_parameters();
CaliAli_options = CaliAli_align_sessions(CaliAli_options);
```


