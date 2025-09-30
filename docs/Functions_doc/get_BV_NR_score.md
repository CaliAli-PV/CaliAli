### get_BV_NR_score {#get_BV_NR_score}

#### Syntax:

```matlab
function out=get_BV_NR_score(P,k) 
```
#### Description:

Compute blood vessel non-rigid alignment stability score.

#### Inputs:

| Parameter Name | Type          | Description                                |
|---------------|---------------|--------------------------------------------|
| P             | Table         | Table containing projection data from session alignment. |
| k             | Optional      | Index of the projection to evaluate. Default is 3 (Neurons). |

#### Outputs:

| Parameter Name | Type          | Description                                |
|---------------|---------------|--------------------------------------------|
| out           | Stability score | Stability score indicating the reliability of blood vessel alignment. |

Example usage:
```matlab
score = get_BV_NR_score(P);
score = get_BV_NR_score(P, 2);
```

!!! note
   - Compares alignment variability across multiple randomized non-rigid motion perturbations.
   - Uses correlation distance to quantify alignment consistency.
   - Ensures reproducibility by setting a fixed random seed.
