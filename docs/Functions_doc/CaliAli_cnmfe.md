### CaliAli_cnmfe {#CaliAli_cnmfe}

#### Syntax
```matlab
function CaliAli_cnmfe()
```

#### Description
CaliAli_cnmfe: Runs CNMF-E for source extraction in neuron or dendrite imaging data.

##### Function Inputs:
This function prompts the user to select .mat files containing the imaging data and CNMF-E parameters. 
The selected files should follow the naming pattern `*_ds*.mat`.


##### Function Outputs:
This function does not return an output but processes each selected file 
and saves the extracted neuron or dendrite components to the workspace.


##### Example usage:
```matlab
CaliAli_cnmfe();
```
