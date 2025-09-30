### Non_rigid_mc {#Non_rigid_mc}

```matlab
function V = Non_rigid_mc(V, ref, opt)
```

#### Description
This function applies non-rigid motion correction to an input video using a
multi-level registration approach. It constructs a pyramid of images (e.g.,
blood vessel and neuron projections) and applies log-domain demons registration
to align frames while preserving fine details.
!!! warning
    This code is experimental and may introduce undesired deformations when adjusting for non-rigid deformation.

#### Function Inputs:
| Parameter Name | Type   | Description                      |
|---------------|--------|----------------------------------|
| V             | 3D array | Input video as a height x width x frames array.|
| ref           | Array  | Reference image for initial alignment.|
| opt           | Structure| Structure containing registration options. |

#### Function Outputs:
| Parameter Name | Type   | Description                      |
|---------------|--------|----------------------------------|
| V             | 3D array | Motion-corrected video.          |

#### Example usage:
```matlab
V_corrected = Non_rigid_mc(V, ref, opt);
```
