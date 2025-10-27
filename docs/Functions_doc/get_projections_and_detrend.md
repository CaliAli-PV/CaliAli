### get_projections_and_detrend {#get_projections_and_detrend}

```matlab
function [Y, p, R, CaliAli_options] = get_projections_and_detrend(Y, CaliAli_options)
```

#### Description
Process session data by detrending and computing projections.

This function processes video session data by applying detrending, removing background noise, and calculating projections such as blood vessels, neuron activity, peak-to-noise ratio (PNR), and correlation images. Prior to saving, the detrended stack is clipped to `uint16`; if more than 1% of the pixels saturate the ceiling, a coloured warning appears in the MATLAB console so you can revisit preprocessing settings.

##### Function Inputs:
| Parameter Name | Type    | Description                                      |
|----------------|---------|--------------------------------------------------|
| Y              | 3D array | Input video session data as a height x width x frames array. |
| CaliAli_options| Structure| Configuration options for processing, details in CaliAli_demo_parameters(). |

##### Function Outputs:
| Parameter Name | Type    | Description                                      |
|----------------|---------|--------------------------------------------------|
| Y              | 3D array | Detrended and background-corrected video data.   |
| p              | Table   | Table containing projections: mean image, blood vessels, neuron projection, PNR, and a fused BV-neuron image.|
| R              | Data range| Data range after detrending, used for normalization. |
| CaliAli_options| Structure| Updated options structure after processing.     |

##### Example usage:
```matlab
[Y, p, R, CaliAli_options] = get_projections_and_detrend(Y, CaliAli_options);
```
