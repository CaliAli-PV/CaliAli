### CaliAli_save {#CaliAli_save}

```matlab
function CaliAli_save(filename, varargin)
```

#### Description
CaliAli_save: Save or append variables to a MAT-file.

##### Function Inputs:
| Parameter Name | Type   | Description                              |
|---------------|--------|------------------------------------------|
| filename      | String | String specifying the file path to save or append data. |
| varargin      | List   | List of variables to be saved.            |

##### Function Outputs:
| Parameter Name | Type | Description                      |
|---------------|------|----------------------------------|
| None          | None | Data is saved to the specified file. |

##### Example usage:
```matlab
CaliAli_save('output.mat', var1, var2);
```
