### CaliAli_remove_background {#CaliAli_remove_background}

```matlab
function Y = CaliAli_remove_background(Y, CaliAli_options)
```

#### Description
CaliAli_remove_background: Preprocess video by removing background noise and enhancing features.

This function applies background removal techniques to enhance neuronal or dendritic structures in an image or video. It supports detrending, noise scaling, and feature enhancement using the MIN1PIPE algorithm.

##### Function Inputs:
| Parameter Name | Type   | Description                                                                 |
|---------------|--------|-----------------------------------------------------------------------------|
| Y               | 3D array | Input image or video as a 3D array.                                        |
| [CaliAli_options](CaliAli_parameters.md) | Structure | Structure containing preprocessing parameters. See `CaliAli_demo_parameters()` for details.|

##### Function Outputs:
| Parameter Name | Type   | Description                                                                 |
|---------------|--------|-----------------------------------------------------------------------------|
| Y             | 3D array | Background-corrected image or video.                                     |

##### Example usage:
```matlab
Y = CaliAli_remove_background(Y, CaliAli_options);
```

Notes:

- Detrending removes slow fluctuations in brightness.
- Noise scaling adjusts pixel noise levels for consistency.
- Neuronal and dendritic enhancement is performed based on the specified structure type ('neuron' or 'dendrite').
- A second noise scaling pass is applied after background removal.
- When `force_non_negative` is enabled, the data are lifted by `force_non_negative_tolerance` and clipped after noise scaling, yielding non-negative intensities without over-suppressing dim fluctuations. Status messages are printed with coloured output.
- Set `preprocessing.median_filtering = [m n]` to apply a per-frame `medfilt2` pass (kernel `[m n]`) before enforcing non-negativity, clipping the extreme pixels that noise scaling can amplify near vignetted borders while keeping broader features intact.
