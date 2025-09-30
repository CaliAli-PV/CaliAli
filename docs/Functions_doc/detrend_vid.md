### detrend_vid {#detrend_vid}

```matlab
function Y=detrend_vid(Y,CaliAli_options)
```

#### Description
`detrend_vid`: Remove slow fluctuations in brightness from video data.

This function performs detrending on a video by applying a moving median
filter followed by a moving minimum filter. It helps to correct slow
fluctuations in intensity over time.

##### Function Inputs:
| Parameter Name | Type    | Description                                           |
|----------------|---------|-------------------------------------------------------|
| Y              | 3D array | Input video as a height x width x frames array.        |
|  [CaliAli_options](CaliAli_parameters.md) | Structure| Structure containing preprocessing parameters. The details of this structure can be found in `CaliAli_demo_parameters()`. |

##### Function Outputs:
| Parameter Name | Type    | Description                                           |
|----------------|---------|-------------------------------------------------------|
| Y              | 3D array | Detrended video with slow fluctuations removed.       |

##### Example usage:
```matlab
Y_detrended = detrend_vid(Y, CaliAli_options);
```

!!! note
    - The moving median filter operates over a window size determined by the product of the sampling frequency and the detrending factor.
    - A secondary moving minimum filter is applied to further refine background fluctuations.
    - Negative values are clipped to zero after detrending forcing non-negative data.