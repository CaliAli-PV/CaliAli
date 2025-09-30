### get_alignment_metrics {#get_alignment_metrics}

```matlab
function T=get_alignment_metrics(P)
```

#### Description
`get_alignment_metrics`: Compute alignment quality metrics for different transformations.

##### Function Inputs:
| Parameter Name | Type   | Description                      |
|----------------|--------|----------------------------------|
| P              | Table  | Table containing different alignment transformations and their projections. |

##### Function Outputs:
| Parameter Name | Type   | Description                      |
|----------------|--------|----------------------------------|
| T              | Table  | Table containing alignment metrics such as correlation scores and crispness. |

##### Example usage:
```matlab
T = get_alignment_metrics(P);
```

#### Notes:
- Evaluates alignment quality using correlation and sharpness metrics.
- Computes alignment metrics for neuron projections.
- Supports additional metrics for blood vessel projections (commented in the cod