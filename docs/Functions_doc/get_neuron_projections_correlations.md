### get_neuron_projections_correlations {#get_neuron_projections_correlations}

#### Syntax
```matlab
function [out,W]=get_neuron_projections_correlations(P,k) 
```

#### Description

Compute correlation metrics for neuron projections.

#### Inputs:

| Parameter Name | Type          | Description                                           |
|----------------|---------------|-------------------------------------------------------|
| P              | Table         | Table containing neuron projection data.             |
| k              | Optional      | Index of the projection to evaluate. k = 1 Mean projections, k = 2 Blood vessels, k = 3 Neuron, k = 4 PNR image  |




#### Outputs:

| Parameter Name | Type    | Description                                      |
|----------------|---------|--------------------------------------------------|
| out            | Double  | Minimum correlation deviation across projections.|
| W              | Double  | Weighting factor based on projection correlation.|

#### Example usage:

```matlab
[out, W] = get_neuron_projections_correlations(P);
[out, W] = get_neuron_projections_correlations(P, 2);
```

Notes:
- Uses normalized cross-correlation to compare neuron projections across sessions.
- Computes mean and standard deviation of correlation within a limited region.
- Flags sessions with low correlation for further inspection.
