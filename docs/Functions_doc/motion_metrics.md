### motion_metrics {#motion_metrics}

```matlab
function [cY,mY,ng] = motion_metrics(Y,bnd,batch_size,var_name)
```

#### Description
`motion_metrics`: Compute correlation and gradient metrics for motion assessment.

##### Function Inputs:
| Parameter Name | Type   | Description                                                                 |
|---------------|--------|-----------------------------------------------------------------------------|
| Y             | 3D/4D array or memory-mapped array | Registered time series data, either a 3D or 4D array, or a memory-mapped array. |
| bnd           | Array  | (Optional) Number of pixels to exclude at borders to avoid NaN effects. Format: [x_beg, x_end, y_beg, y_end, z_beg, z_end]. Default is [0, 0, 0, 0, 0, 0]. |
| batch_size    | Scalar | (Optional) Batch size for processing memory-mapped files. Default: 1000.     |
| var_name      | String | (Optional) Variable name for memory-mapped files.                           |

##### Function Outputs:
| Parameter Name | Type   | Description                                      |
|---------------|--------|--------------------------------------------------|
| cY            | Array  | Correlation coefficient of each frame with the mean image.       |
| mY            | Array  | Mean image computed from all frames.               |
| ng            | Scalar | Norm of the gradient of the mean image.             |

##### Example usage:
```matlab
[cY, mY, ng] = motion_metrics(Y);
[cY, mY, ng] = motion_metrics(Y, [10,10,10,10,0,0], 500);
```
