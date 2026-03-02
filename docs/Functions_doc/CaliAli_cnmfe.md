### CaliAli_cnmfe {#CaliAli_cnmfe}

#### Syntax
```matlab
function file_path = CaliAli_cnmfe(input_files)
```

#### Description
CaliAli_cnmfe: Runs CNMF-E for source extraction in neuron or dendrite imaging data.

##### Function Inputs:
- `input_files` (optional): Path, string, or cell array of `.mat` files to process.
- If omitted, CaliAli opens a file picker.
- Typical inputs are aligned or detrended outputs (for example `*_Aligned.mat` or `*_det.mat`).


##### Function Outputs:
- `file_path`: Cell array with the processed file paths.


##### Example usage:
```matlab
CaliAli_cnmfe();
```

```matlab
file_path = CaliAli_cnmfe(CaliAli_options.inter_session_alignment.out_aligned_sessions);
```
