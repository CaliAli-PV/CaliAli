### CaliAli_update_parameters {#CaliAli_update_parameters}

```matlab
function CaliAli_update_parameters(varargin)
```

#### Description
CaliAli_update_parameters: Update parameters in multiple CaliAli session files.

A file browser opens to pick the `.mat` files. Each parameter you pass is changed wherever it appears in the options saved in those files.

##### Function Inputs:
| Parameter Name | Type    | Description                                      |
|---------------|---------|--------------------------------------------------|
| varargin      | name/value pairs | Names and new values of the parameters to change, or a structure holding only those parameters. Parameters whose value is a structure (such as `deconv_options`) cannot be changed this way.|

!!! warning
    Pass only the parameters you want to change. Do not pass a full `CaliAli_options` structure: it overwrites the data saved in the files, including the alignment results.

##### Function Outputs:
None: Updates and saves modified parameters in selected .mat files.

##### Example usage:
```matlab
CaliAli_update_parameters('sf', 15, 'detrend', 2);

new_values.min_corr = 0.2;
new_values.min_pnr = 5;
CaliAli_update_parameters(new_values);
```
