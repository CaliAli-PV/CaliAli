### dissimilarity_previous {#dissimilarity_previous}

```matlab
function [dis, similarity_per_component, previous_index] = dissimilarity_previous(A1, A2, C1, C2)
```

#### Description
Computes the dissimilarity between the components of two consecutive CNMF-E iterations. Each updated component is matched to its most similar previous component, using both spatial footprints and temporal traces.

##### Function Inputs:
| Parameter Name | Type   | Description                     |
|---------------|--------|---------------------------------|
| A1            | matrix | Spatial footprints of the previous components. |
| A2            | matrix | Spatial footprints of the updated components. |
| C1            | matrix | Temporal activity traces of the previous components. |
| C2            | matrix | Temporal activity traces of the updated components. |

##### Function Outputs:
| Parameter Name | Type  | Description                               |
|---------------|-------|-------------------------------------------|
| dis           | scalar | Dissimilarity between previous and updated components (`1` minus the mean temporal similarity of matched pairs). Lower means more similar. |
| similarity_per_component | vector | One entry per updated component: temporal similarity to its matched previous component, or `NaN` if it has no match (for example, a new component). |
| previous_index | vector | One entry per updated component: index of the matched component in `A1`/`C1`, or `NaN` if unmatched. |

##### Example usage:
```matlab
dis = dissimilarity_previous(A1, A2, C1, C2);
[dis, similarity_per_component, previous_index] = dissimilarity_previous(A1, A2, C1, C2);
```
