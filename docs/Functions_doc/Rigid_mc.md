### Rigid_mc {#Rigid_mc}

#### Syntax
```matlab
function [Mr, Ref, template, valid] = Rigid_mc(Y, opt, template)
```

#### Description
This function applies rigid motion correction (whole-frame shifts) to a video using the NoRMCorre algorithm. Shifts are estimated on a reference projection of each frame: blood vessels (`reference_projection_rigid = 'BV'`) or background-removed neurons (`'neuron'`).

##### Function Inputs:
| Parameter Name | Type   | Description                         |
|----------------|--------|-------------------------------------|
| Y              | 3D array | Video to be motion corrected (height x width x frames). |
| opt            | Structure | Motion correction options (`CaliAli_options.motion_correction`). |
| template       | 2D array | (Optional) Template returned by a previous call. Pass it when correcting later chunks of the same session so all chunks are registered to the same image. |

##### Function Outputs:
| Parameter Name | Type   | Description                         |
|----------------|--------|-------------------------------------|
| Mr             | 3D array | Motion-corrected video, same size and class as `Y`. |
| Ref            | 3D array | Reference projection of every frame (`uint16`), shifted in the same way as `Mr`. |
| template       | 2D array | Template the frames were registered to. |
| valid          | Logical matrix | `true` where every frame holds real data after shifting. |

##### Example usage:
```matlab
opt = CaliAli_options.motion_correction;
[Mr, Ref, template, valid] = Rigid_mc(Y1, opt);       % first chunk
[Mr2, ~, ~, valid2] = Rigid_mc(Y2, opt, template);    % next chunk of the same session
```
