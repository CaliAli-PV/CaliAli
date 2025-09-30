
### apply_crop_on_disk {#apply_crop_on_disk}

#### Syntax
```matlab
function apply_crop_on_disk(mat_path, varname)
```

#### Description
`apply_crop_on_disk` trims zero-padded borders from a motion-corrected video directly on disk. It reads the stored `CaliAli_options.motion_correction.Mask`, crops `varname` (default `Y`) in streaming chunks that respect the configured `batch_sz`, and saves the result back into the same MAT-file.

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `mat_path`     | char | Path to the MAT-file that contains the video stack and `CaliAli_options`. |
| `varname`      | char | (Optional) Name of the variable to crop. Defaults to `'Y'`. |

##### Notes
- Requires `CaliAli_options.motion_correction.Mask` and `batch_sz` to be present inside the MAT-file.
- Performs the copy in batches to avoid loading the full dataset into memory.
- The original file is replaced atomically after the temporary cropped copy is written.

##### Example Usage
```matlab
apply_crop_on_disk('session1_mc.mat');
```
