### CNMFE_parameters {#CNMFE_parameters}

```matlab
function pars=CNMFE_parameters(varargin)
```

#### Description
CNMFE_parameters: Define and configure parameters for CNMF-E processing.

This function initializes and returns a structured set of parameters for
constrained non-negative matrix factorization (CNMF-E), including spatial,
temporal, background, and merging constraints for neuronal extraction.

##### Function Inputs:
| Parameter Name | Type         | Description                                      |
|----------------|--------------|--------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md) | Structure    | Contains configuration options.|

##### Function Inputs:
| Parameter Name | Type         | Description                                      |
|----------------|--------------|--------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md) | Structure    | CaliAli_options structure parsed with CNMF parameters.|

##### Example usage:
```matlab
pars = CNMFE_parameters();   % Default parameter initialization
pars = CNMFE_parameters(existing_pars);   % Use existing parameter structure
```

