### CNMFE_parameters {#CNMFE_parameters}

```matlab
function pars=CNMFE_parameters(varargin)
```

#### Description
CNMFE_parameters: Define and configure parameters for CNMF-E processing.

This function initializes and returns a structured set of parameters for
constrained non-negative matrix factorization (CNMF-E), including spatial,
temporal, background, and merging constraints for neuronal extraction.

It is called by [CaliAli_parameters](CaliAli_parameters.md); set CNMF-E parameters there rather than calling this function directly.

##### Function Inputs:
| Parameter Name | Type         | Description                                      |
|----------------|--------------|--------------------------------------------------|
| varargin | Structure    | CNMF-E settings to change; anything not set keeps its default.|

##### Function Outputs:
| Parameter Name | Type         | Description                                      |
|----------------|--------------|--------------------------------------------------|
| pars | Structure    | CNMF-E parameters, stored by `CaliAli_parameters` as `CaliAli_options.cnmf`.|

##### Example usage:
```matlab
CaliAli_options = CaliAli_parameters('min_pnr', 4);   % calls CNMFE_parameters
pars = CaliAli_options.cnmf;                          % the CNMF-E parameters
```

