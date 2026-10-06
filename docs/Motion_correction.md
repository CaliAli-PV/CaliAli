# Motion Correction

After downsampling, correct motion artifacts in each session.

Use:

```matlab
CaliAli_options = CaliAli_motion_correction(CaliAli_options);
```	

!!! success "Output File"
    This step creates `*_mc.mat` files. For naming and save-location details, see [FAQ output naming](FAQ.md#output-files).

!!! danger "Important"
    Ensure to visually inspect the motion-corrected video before proceeding to the next step: [**view_Ca_video()**](Functions_doc/view_Ca_video.md#view_Ca_video)

---    

??? Info "Non-rigid correction"
    Off by default. The rigid stage corrects whole-frame shifts, which is enough for most recordings. Turn non-rigid correction on only if, after rigid correction, parts of the field of view still move relative to each other:

    ```matlab
    CaliAli_options.motion_correction.do_non_rigid = true;
    CaliAli_options.motion_correction.non_rigid_levels = 1;  % optional
    ```

    - `non_rigid_levels = 1` (default) corrects local deformation on a coarse 3×3 grid. Each extra level adds a finer grid (4×4, 5×5, …) that refines what the previous level left, at the cost of another registration pass.
    - Compare the output against the rigid-only result with [view_Ca_video()](Functions_doc/view_Ca_video.md#view_Ca_video). Keep non-rigid correction only if local drift is visibly reduced and the field of view is not warped.

??? tip "Crop after motion correction"
    Use [CaliAli_crop()](Functions_doc/CaliAli_crop.md#CaliAli_crop) to interactively draw a shared region of interest across the motion-corrected sessions. The tool opens representative frames, lets you define the final field of view, and rewrites each `_mc` file in-place so downstream detrending and alignment run on the trimmed data.



=== "Next"	
After finishing downsampling and motion correction you can proceed to [Inter-session Alignment](alignment.md)
