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

## Non-rigid motion correction <a id="non-rigid"></a>

By default CaliAli applies rigid correction, which shifts the whole frame and is enough for most recordings. If parts of the field of view still move relative to each other afterwards, turn on non-rigid correction, which corrects each region of the frame separately.

Set it in your parameter file (`CaliAli_demo_parameters.m`, see [Recommended Parameter Workflow](Parameters.md#parameter-workflow)):

```matlab
params.do_non_rigid = true;    % off by default
params.non_rigid_levels = 1;   % 1 = coarse 3×3 grid; each extra level adds a finer grid (4×4, 5×5, …)
```

Start with `non_rigid_levels = 1`. Higher levels correct finer deformations, but each one adds another registration pass.

To judge the result, compare it with the rigid-only output in [view_Ca_video()](Functions_doc/view_Ca_video.md#view_Ca_video). Keep non-rigid correction only if local drift is visibly reduced and the field of view is not warped.

!!! note "Changed in 1.5.0"
    Non-rigid correction now uses the NoRMCorre engine. Older scripts that set `non_rigid_pyramid`, `non_rigid_options` or `non_rigid_batch_size` still run, but those settings are ignored.

??? tip "Crop after motion correction"
    Use [CaliAli_crop()](Functions_doc/CaliAli_crop.md#CaliAli_crop) to interactively draw a shared region of interest across the motion-corrected sessions. The tool opens representative frames, lets you define the final field of view, and rewrites each `_mc` file in-place so downstream detrending and alignment run on the trimmed data.



=== "Next"	
After finishing downsampling and motion correction you can proceed to [Inter-session Alignment](alignment.md)
