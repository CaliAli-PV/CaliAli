```matlab
function dis=dissimilarity_previous(A1,A2,C1,C2)
```

#### Description
Computes the dissimilarity between spatial and temporal components.

##### Function Inputs:
| Parameter Name | Type   | Description                     |
|---------------|--------|---------------------------------|
| A1            | matrix | Spatial footprints of extracted components (matrices). |
| A2            | matrix | Spatial footprints of extracted components (matrices). |
| C1            | matrix | Temporal activity traces of extracted components (matrices). |
| C2            | matrix | Temporal activity traces of extracted components (matrices). |

##### Function Outputs:
| Parameter Name | Type  | Description                               |
|---------------|-------|-------------------------------------------|
| dis           | scalar | A scalar value representing the dissimilarity between previous and updated components. |

##### Example usage:
```matlab
dis = dissimilarity_previous(A1, A2, C1, C2);
```
