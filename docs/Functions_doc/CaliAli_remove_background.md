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
| [CaliAli_options](../../Functions_doc/CaliAli_parameters) | Structure | Structure containing preprocessing parameters. See `CaliAli_demo_parameters()` for details.|

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
