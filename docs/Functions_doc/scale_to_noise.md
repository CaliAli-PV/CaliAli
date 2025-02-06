```matlab
function scale_to_noise(neuron)
```

#### Description
`scale_to_noise`: Normalizes raw calcium traces based on estimated noise levels.

##### Function Inputs:
| Parameter Name | Type   | Description              |
|----------------|--------|--------------------------|
| neuron         | `Sources2D` object | A `Sources2D` object containing extracted calcium signals and options.|

##### Function Outputs:
| Parameter Name | Type    | Description                            |
|----------------|---------|----------------------------------------|
| (none)         | -       | The function modifies `neuron.C_raw` in place, normalizing calcium traces using noise estimates.|

##### Example usage:
```matlab
scale_to_noise(neuron);
```

 - This function estimates the noise level by computing the residual between the raw calcium trace (`C_raw`) and the deconvolved signal.
 - A moving window approach is used to handle large datasets.

!!! warning
    - Running this function modifies the temporal traces in a way that makes them unsuitable for further CNMF iterations. If additional CNMF iterations are needed, `neuron=CNMF_CaliAli_update('Temporal',neuron);` must be rerun to restore a compatible state.
    