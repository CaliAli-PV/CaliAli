### get_projections_and_detrend {#get_projections_and_detrend}

```matlab
function [Y, p, R, CaliAli_options] = get_projections_and_detrend(Y, CaliAli_options, target_class)
```

#### Description
Process session data by detrending and computing projections.

This function processes video session data by applying detrending, removing background noise, and calculating projections such as blood vessels, neuron activity, peak-to-noise ratio (PNR), and correlation images. The detrended video is converted to `target_class`, and values above that class's maximum are clipped; if 1% or more of the pixels are clipped, a red warning appears in the MATLAB console so you can revisit preprocessing settings.

##### Function Inputs:
| Parameter Name | Type    | Description                                      |
|----------------|---------|--------------------------------------------------|
| Y              | 3D array | Input video session data as a height x width x frames array. |
| CaliAli_options| Structure| Configuration options for processing, details in CaliAli_demo_parameters(). |
| target_class   | String  | (Optional) Class of the returned video: `'uint8'`, `'uint16'` or `'uint32'`. Default: `'uint16'`. |

##### Function Outputs:
| Parameter Name | Type    | Description                                      |
|----------------|---------|--------------------------------------------------|
| Y              | 3D array | Detrended and background-corrected video data, of class `target_class`. |
| p              | Table   | Table containing projections: `Mean` (median frame), `BloodVessels`, `Neurons`, `PNR`, and `BV+Neurons` (fused image).|
| R              | Scalar  | Maximum value after detrending (before clipping), used for normalization. |
| CaliAli_options| Structure| Updated options structure after processing.     |

##### Example usage:
```matlab
[Y, p, R, CaliAli_options] = get_projections_and_detrend(Y, CaliAli_options, 'uint16');
```
