### Non_rigid_mc {#Non_rigid_mc}

```matlab
function [V, valid] = Non_rigid_mc(V, ref, opt)
```

#### Description
Corrects non-rigid motion with NoRMCorre: the frame is split into a grid of patches and each patch gets its own shift. [CaliAli_motion_correction](CaliAli_motion_correction.md#CaliAli_motion_correction) runs it after [Rigid_mc](Rigid_mc.md#Rigid_mc) when `do_non_rigid = true`. See [Non-rigid motion correction](../Motion_correction.md#non-rigid) for when to turn it on and how to check the result.

#### Function Inputs:
| Parameter Name | Type   | Description                      |
|---------------|--------|----------------------------------|
| V             | 3D array | Video (height x width x frames), already corrected by `Rigid_mc`. |
| ref           | 3D array | Reference returned by `Rigid_mc`. Accepted but not used. |
| opt           | Structure| Motion correction options (`CaliAli_options.motion_correction`). Reads `non_rigid_levels` (number of grid levels, default `1`) and `non_rigid_highpass_sigma` (size in pixels of the background removed before matching patches, default `6`). |

#### Function Outputs:
| Parameter Name | Type   | Description                      |
|---------------|--------|----------------------------------|
| V             | 3D array | Motion-corrected video, same size and class as the input. |
| valid         | Logical matrix | `true` where every frame still holds real data after correction. |

#### Example usage:
```matlab
opt = CaliAli_options.motion_correction;
[Y, ref, ~, valid] = Rigid_mc(Y, opt);
[Y, valid_nr] = Non_rigid_mc(Y, ref, opt);
valid = valid & valid_nr;
```
