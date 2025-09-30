### get_local_corr_Vf {#get_local_corr_Vf}

```matlab
function mc=get_local_corr_Vf(Vf,M) 
```
#### Description
get_local_corr_Vf: Compute local correlation-based similarity for vesselness-filtered data.

#### Inputs:

| Parameter Name | Type   | Description                               |
|---------------|--------|-------------------------------------------|
| Vf            | 3D array| Contains vesselness-filtered images (blood vessels). |
| M             | 3D array| Represents the mean reference image.     |

#### Outputs:

| Parameter Name | Type   | Description                          |
|---------------|--------|--------------------------------------|
| mc            | 2D array| Represents the computed local correlation-based similarity map. |

#### Example usage:
```matlab
mc = get_local_corr_Vf(Vf, M);
```

