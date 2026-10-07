### CaliAli_parameters {#CaliAli_parameters}

```matlab
function opt=CaliAli_parameters(varargin)
```

#### Description
CaliAli_parameters: Initialize and configure parameters for CaliAli processing.

This function initializes and returns a structured set of parameters for different stages of the CaliAli processing pipeline, including downsampling, preprocessing, motion correction, inter-session alignment, and CNMF-E.

##### Function Inputs:
| Parameter Name | Type   | Description                                             |
|----------------|--------|---------------------------------------------------------|
| varargin       | array  | Variable input arguments, which can be an existing structure or key-value pairs specifying parameters. |

##### Function Outputs:
| Parameter Name | Type    | Description                                  |
|----------------|---------|----------------------------------------------|
| opt            | struct  | Structure containing all processing parameters. |

##### Example usage:
```matlab
opt = CaliAli_parameters();   % Default parameter initialization
opt = CaliAli_parameters(existing_opt);   % Use existing parameter structure
opt = CaliAli_parameters('sf',20);   % Set sampling frequency to 20 fps.
```

#### Notes:
- Each processing step has its own sub-structure: `opt.downsampling`, `opt.preprocessing`, `opt.motion_correction`, `opt.inter_session_alignment` and `opt.cnmf`.
- A parameter set once (as a name/value pair or a top-level field) is copied to every step that uses it. To change it for one step only, set it in that step's sub-structure; see [Parameter settings](../Parameters.md#per-step).
- When `gSig` is omitted, it is set to `5 / spatial_ds`.
- Default values are listed in the [parameter index](../Parameters_index.md); [CaliAli_demo_parameters](CaliAli_demo_parameters.md) shows the values used by the demo.
