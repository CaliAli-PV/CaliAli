### postprocessDeconvolvedTraces {#postprocessDeconvolvedTraces}

```matlab
function neuron = postprocessDeconvolvedTraces(neuron, method, type, smin)
```

#### Description
This function applies deconvolution to calcium traces and performs post-processing to denoise the traces based on specified options. It allows users to change the autoregressive model (`ar1`, `ar2`, etc.) at the end of CNMF iterations for refined neuronal activity estimation.

##### Function Inputs:
| Parameter Name | Type    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| neuron        | struct  | A struct containing the raw calcium traces (neuron.C_raw).                 |
| method        | string  | The deconvolution method to use (default: `final_deconv_options.method`, 'foopsi'). |
| type          | string  | The type of deconvolution (default: `final_deconv_options.type`, 'ar2'). |
| smin          | double  | Minimum threshold for deconvolution (default: `final_deconv_options.smin`, -5). |

##### Function Outputs:
| Parameter Name | Type    | Description                                         |
|---------------|---------|-----------------------------------------------------|
| neuron        | struct  | Updated struct with processed calcium traces (neuron.C and neuron.S). |

##### Example usage:
```matlab
neuron = postprocessDeconvolvedTraces(neuron);
neuron = postprocessDeconvolvedTraces(neuron, 'thresholded', 'ar1', -3);
```

   - It allows users to change the autoregressive model (`ar1`, `ar2`, etc.) at the end of CNMF iterations for refined neuronal activity estimation.
   - This is particularly useful if a fast deconvolution method (e.g., `foopsi`) was used during CNMF iterations, and a more precise but slower thresholded method is desired  for final processing.

!!! note "Run after `scale_to_noise`"
    `neuron.C_raw` must be in noise units, as left by [scale_to_noise()](scale_to_noise.md#scale_to_noise): the deconvolution assumes a noise level of 1, and `smin` is read in noise units. [CaliAli_cnmfe()](CaliAli_cnmfe.md#CaliAli_cnmfe) already runs both functions in this order.

!!! warning
    - Running this function modifies the temporal traces in a way that makes them unsuitable for further CNMF iterations. If additional CNMF iterations are needed, `neuron=CNMF_CaliAli_update('Temporal',neuron);` must be rerun to restore a compatible state.
    
