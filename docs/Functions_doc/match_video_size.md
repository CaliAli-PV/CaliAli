```matlab
function CaliAli_options = match_video_size(CaliAli_options)
```

#### Description
Ensure consistent video dimensions across sessions.

This function aligns video dimensions across multiple sessions by cropping borders to match a common mask. It ensures that sessions dimensions match before performing inter-session alignment.

##### Function Inputs:
| Parameter Name | Type    | Description                                       |
|----------------|---------|---------------------------------------------------|
| CaliAli_options| Structure| Structure containing configuration options for alignment.|

The details of this structure can be found in CaliAli_demo_parameters().

##### Function Outputs:
| Parameter Name | Type    | Description                                       |
|----------------|---------|---------------------------------------------------|
| CaliAli_options| Structure| Updated structure with matched video dimensions.  |

##### Example usage:
```matlab
CaliAli_options = match_video_size(CaliAli_options);
```
