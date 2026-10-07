### vesselness_PV {#vesselness_PV}

```matlab
function vid=vesselness_PV(vid,use_parallel,sz,norm)
```

#### Description
This function enhances blood vessels in an input image or video using a Hessian-based vesselness filter adapted from the Jerman filter. It supports both sequential and parallel processing.

##### Function Inputs:
| Parameter Name | Type    | Description                                   |
|---------------|---------|-----------------------------------------------|
| vid           | 2D/3D array | Input image or video as a 2D or 3D array.     |
| use_parallel  | Boolean | (Optional) Boolean flag to enable parallel processing (default: 1). |
| sz            | Vector  | (Optional) Scale range for the vesselness filter (default: 0.5:0.5:2). |
| norm          | Scalar  | (Optional) How the responses at the different scales in `sz` are combined: `0` sum (default), `1` maximum after rescaling each scale to [0, 1], `2` maximum without rescaling. |

##### Function Outputs:
| Parameter Name | Type    | Description                      |
|---------------|---------|----------------------------------|
| vid           | 2D/3D array | Image or video with enhanced blood vessels. |

##### Example usage:
```matlab
vid_filtered = vesselness_PV(vid);   % Default parameters with parallel processing
vid_filtered = vesselness_PV(vid, 0, 0.5:0.5:2, 1);   % Sequential processing, maximum of rescaled responses
```

#### Notes:
- Uses vesselness filtering to enhance tubular structures in images.
- Parallel processing is available for large videos to improve efficiency.
