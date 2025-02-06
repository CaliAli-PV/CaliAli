#### Syntax
```matlab
function M=CaliAli_get_blood_vessels(M,CaliAli_options)
```

#### Description
Enhance blood vessels in an image or video using a combination of vignetting removal, hessian filtering, and median filtering.

##### Function Inputs:
| Parameter Name | Type    | Description                                      |
|----------------|---------|--------------------------------------------------|
| M              | 2D/3D array | Input image or video as a grayscale or color array.|
| [CaliAli_options](../../Functions_doc/CaliAli_parameters)      | Structure | Optional structure containing processing parameters:<br>- `opt.BVsize`: 2-element vector specifying the range of vessel scales (in pixels) for the vesselness filter (default: [1.5, 2.25]). |

##### Function Outputs:
| Parameter Name | Type    | Description                                      |
|----------------|---------|--------------------------------------------------|
| M              | 2D/3D array | Processed image or video with enhanced blood vessels.|

##### Example usage:
```matlab
M = CaliAli_get_blood_vessels(M, CaliAli_options);
```