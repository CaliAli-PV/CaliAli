### scale_to_noise {#scale_to_noise}

```matlab
function scale_to_noise(neuron)
```

#### Description
`scale_to_noise`: Expresses the raw calcium traces in noise units, so that a value of 1 equals the noise level of each trace, and then deconvolves them again.

##### Function Inputs:
| Parameter Name | Type   | Description              |
|----------------|--------|--------------------------|
| neuron         | `Sources2D` object | A `Sources2D` object containing extracted calcium signals and options.|

##### Function Outputs:
| Parameter Name | Type    | Description                            |
|----------------|---------|----------------------------------------|
| (none)         | -       | The function modifies `neuron` in place: `neuron.C_raw` is rescaled, and `neuron.C` and `neuron.S` are replaced by a new deconvolution.|

##### Example usage:
```matlab
scale_to_noise(neuron);
```

 - Each trace is detrended and divided by its noise level. The noise is estimated separately for each batch of frames used during extraction.
 - The scaling applied is stored in `neuron`, so functions that need the traces on the original scale (such as [manually_update_residuals](manually_update_residuals.md#manually_update_residuals)) can undo it.
 - The traces are then deconvolved again with the deconvolution settings stored in `neuron` (this overwrites `neuron.C` and `neuron.S`).
 - [CaliAli_cnmfe()](CaliAli_cnmfe.md#CaliAli_cnmfe) already runs this function at the end of the extraction.

!!! warning
    - Running this function modifies the temporal traces in a way that makes them unsuitable for further CNMF iterations. If additional CNMF iterations are needed, `neuron=CNMF_CaliAli_update('Temporal',neuron);` must be rerun to restore a compatible state.
    
