### update_residual_Cn_PNR_batch {#update_residual_Cn_PNR_batch}

```matlab
function neuron=update_residual_Cn_PNR_batch(neuron)
```

#### Description
Calculate Cn and PNR neuron projections from the residual video.

##### Function Inputs:
| Parameter Name | Type   | Description          |
|---------------|--------|----------------------|
| neuron        | struct | A structure containing neuron data and parameters.|

##### Function Outputs:
| Parameter Name | Type   | Description          |
|---------------|--------|----------------------|
| neuron        | struct | The updated neuron structure with CNr and PNRr (residual projections) |

##### Example usage:
```matlab
neuron = update_residual_Cn_PNR_batch(neuron);
```