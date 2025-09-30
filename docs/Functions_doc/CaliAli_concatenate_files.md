### CaliAli_concatenate_files {#CaliAli_concatenate_files}

#### Syntax
```matlab
function out=CaliAli_concatenate_files(outpath,inputh,CaliAli_options)
```

#### Description
Concatenate multiple video files into a single file.

This function merges multiple .mat video files into a single output file. The resulting concatenated video is saved in the specified output path.

##### Function Inputs:
| Parameter Name | Type   | Description                          |
|---------------|--------|--------------------------------------|
| outpath       | String | (Optional) Path to save the output file. If not provided, a default name is generated. |
| inputh        | Cell   | (Optional) Array of paths to input .mat files. If not provided, a file selection dialog is prompted. |
| [CaliAli_options](CaliAli_parameters.md)  | Structure | (Optional) Structure containing processing options. |

##### Function Outputs:
| Parameter Name | Type   | Description                          |
|---------------|--------|--------------------------------------|
| out           | String | Path to the saved concatenated video file. |

##### Example usage:
```matlab
out = CaliAli_concatenate_files();   % Interactive file selection
out = CaliAli_concatenate_files(outpath, inputh, CaliAli_options);   % Using predefined parameters
```
