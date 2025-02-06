```matlab
function vid=vesselness_PV(vid,use_parallel,sz,norm)
```

#### Description
This function enhances blood vessels in an input image or video using frangi filtering. It supports both sequential and parallel processing.

##### Function Inputs:
| Parameter Name | Type    | Description                                   |
|---------------|---------|-----------------------------------------------|
| vid           | 2D/3D array | Input image or video as a 2D or 3D array.     |
| use_parallel  | Boolean | (Optional) Boolean flag to enable parallel processing (default: 1). |
| sz            | Vector  | (Optional) Scale range for the vesselness filter (default: 0.5:0.5:2). |
| norm          | Boolean | (Optional) Normalization flag for vesselness filtering (default: 0). |

##### Function Outputs:
| Parameter Name | Type    | Description                      |
|---------------|---------|----------------------------------|
| vid           | 2D/3D array | Image or video with enhanced blood vessels. |

##### Example usage:
```matlab
vid_filtered = vesselness_PV(vid);   % Default parameters with parallel processing
vid_filtered = vesselness_PV(vid, 0, 0.5:0.5:2, 1);   % Sequential processing with normalization
```

#### Notes:
- Uses vesselness filtering to enhance tubular structures in images.
- Parallel processing is available for large videos to improve efficiency.
- Normalization ensures that vessel structures are highlighted consistently.
