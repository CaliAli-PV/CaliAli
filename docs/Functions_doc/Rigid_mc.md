#### Syntax
```matlab
function [Mr, Ref] = Rigid_mc(Y, opt)
```

#### Description
This function applies rigid motion correction to a 3D image volume using the NoRMCorre algorithm. The correction is based on a reference projection that can be computed using blood vessel extraction or background removal.

##### Function Inputs:
| Parameter Name | Type   | Description                         |
|----------------|--------|-------------------------------------|
| Y              | 3D image volume | The 3D image volume to be motion corrected. |
| opt            | Structure | A structure containing motion correction options. |

##### Function Outputs:
| Parameter Name | Type   | Description                         |
|----------------|--------|-------------------------------------|
| Mr             | 3D image volume | The motion-corrected 3D image volume. |
| Ref            | Reference projection | A reference projection used for motion correction. |

##### Example usage:
```matlab
[Mr, Ref] = Rigid_mc(Y, opt);
```
