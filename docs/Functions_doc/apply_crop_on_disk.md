
### apply_crop_on_disk {#apply_crop_on_disk}

#### Syntax
```matlab
function apply_crop_on_disk(mat_path, varname)
```

#### Description
`apply_crop_on_disk` trims zero-padded borders from a motion-corrected video directly on disk. It reads the stored `CaliAli_options.motion_correction.Mask`, crops `varname` (default `Y`) in streaming chunks that respect the configured `batch_sz`, and saves the result back into the same MAT-file.

This helper is designed for the v1.4 chunked pipeline: once motion correction has written its `_mc.mat` outputs, `apply_crop_on_disk` removes the padded borders without ever loading the full stack into RAM. That keeps disk usage small and ensures subsequent detrending/alignment steps operate on the spatially trimmed movie.

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `mat_path`     | char | Path to the MAT-file that contains the video stack and `CaliAli_options`. |
| `varname`      | char | (Optional) Name of the variable to crop. Defaults to `'Y'`. |

##### Notes
- Requires `CaliAli_options.motion_correction.Mask` and `batch_sz` to be present inside the MAT-file. When motion correction runs with `batch_sz>0`, both fields are created automatically.
- Performs the copy in batches to avoid loading the full dataset into memory. The effective chunk size matches the frames-per-batch selected for motion correction.
- Rewrites the file in-place: the function streams from the existing dataset into a temporary file, then swaps it back onto disk to minimise the risk of leaving half-written outputs if the process stops unexpectedly.
- Detrending and inter-session alignment call this function internally, so you rarely need to invoke it manually unless you are reprocessing legacy datasets.

##### Example Usage
```matlab
apply_crop_on_disk('session1_mc.mat');
```
