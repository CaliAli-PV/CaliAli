
### apply_crop_on_disk {#apply_crop_on_disk}

#### Syntax
```matlab
function apply_crop_on_disk(mat_path, varname)
```

#### Description
`apply_crop_on_disk` crops a motion-corrected video on disk to the bounding box of the valid region recorded in `CaliAli_options.motion_correction.Mask`. It crops `varname` (default `Y`) in chunks of the configured `batch_sz` and saves the result back into the same MAT-file. [CaliAli_motion_correction](CaliAli_motion_correction.md#CaliAli_motion_correction) calls it automatically, so you do not normally need to run it.

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `mat_path`     | char | Path to the MAT-file that contains the video stack and `CaliAli_options`. |
| `varname`      | char | (Optional) Name of the variable to crop. Defaults to `'Y'`. |

##### Notes
- Requires `CaliAli_options.motion_correction.Mask` and `batch_sz` to be present inside the MAT-file.
- Performs the copy in batches to avoid loading the full dataset into memory.
- Run it only once per file: on a file that is already cropped it stops with a `Mask must be [...]` error.
- The rewritten file keeps only `varname` and `CaliAli_options`.
- The cropped copy is written to a temporary file, which then replaces the original.

##### Example Usage
```matlab
apply_crop_on_disk('session1_mc.mat');
```
