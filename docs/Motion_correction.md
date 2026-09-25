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

??? Bug  "Limitations of the non-rigid registration module"
	This code is experimental and may introduce undesired deformations when adjusting for non-rigid deformation.

??? Info "How the non-rigid module works, and what it is worth"
    Non-rigid correction runs after the rigid stage, on what the whole-frame
    shift leaves behind. It uses NoRMCorre in grid mode: the frame is split into
    patches, each gets its own shift, and those are blended into a smooth field.

    **It registers on a high-pass image, not the blood-vessel map.** The vessel
    map is the right reference for the rigid stage, where one shift is estimated
    for the whole frame: its broad correlation peak finds a large displacement
    unambiguously. A patch needs the opposite — a sharp peak — and the width of
    the image's own autocorrelation decides how sharp that is. Measured on this
    pipeline's data, a high pass has an autocorrelation half-width under one
    pixel, while the vessel map and the neuron projection both sit at six.

    **One level by default.** `non_rigid_levels = 1` lays 3 patches across each
    axis. Setting it higher adds a 4×4 level, then 5×5, then 6×6, each
    correcting only the residual the level before it left. A finer grid *on its
    own* is worse, because each patch holds less signal; it only pays inside a
    cascade. Each level costs another registration pass.

    Residual misalignment, measured against the motion the simulator applied,
    on **one** simulated recording with a known 1.5 px rms deformation:

    | | px rms |
    |---|---|
    | before any correction | 2.23 |
    | after the rigid stage | 1.26 |
    | `non_rigid_levels = 1` | 0.76 |
    | `non_rigid_levels = 2` | 0.67 |
    | `non_rigid_levels = 4` | 0.55 |

    Those numbers say the module removes real deformation, and by how much. They
    do **not** say it improves the neurons you get out. Scored against the
    simulated ground truth, the effect on extraction quality changed sign
    between two runs of the same code on different realisations of the same
    simulation, so on this evidence any effect is smaller than the variation
    between recordings. One recording is one sample.

    That is why non-rigid correction is **off by default**. Turn it on if your
    recording visibly deforms; the rigid stage handles everything else.

??? Info "CaliAli uses its own window function for non-rigid registration"
    Non-rigid registration tapers each patch before transforming it, because the
    correlation is circular: a patch's left edge sits next to its right edge, and
    that seam produces a spurious peak at zero shift which biases every estimate
    toward finding no motion.

    NoRMCorre's `han` applies a Hamming window to the raw patch. Hamming bottoms
    out at 0.08 rather than 0, so on a patch carrying any offset most of the seam
    survives. CaliAli uses `caliali_han` instead, which subtracts the patch mean
    first and applies a true Hann taper. With NoRMCorre's version the non-rigid
    module leaves 1.14 px of misalignment where this one leaves 0.76 px, and
    NoRMCorre's is also non-monotonic in the number of levels.

    **The vendored NoRMCorre files are unmodified.** `caliali_han` has its own
    name precisely so that a separate NoRMCorre installation on your path cannot
    shadow it, and CaliAli cannot shadow that installation either. Which one runs
    does not depend on the order your folders were added.

	
??? Info "How long it takes to motion correct videos?"
    - **Rigid**: processes ~5,000 frames in about 2 minutes on a modern CPU. :material-information-outline:{ title="Estimate based on ~300×300 pixel videos." }
	- **Non-rigid**: substantially slower at roughly 10 frames per second. :material-information-outline:{ title="Measured on ~300×300 pixel videos; an updated module is in development." }

??? tip "Crop after motion correction"
    Use [CaliAli_crop()](Functions_doc/CaliAli_crop.md#CaliAli_crop) to interactively draw a shared region of interest across the motion-corrected sessions. The tool opens representative frames, lets you define the final field of view, and rewrites each `_mc` file in-place so downstream detrending and alignment run on the trimmed data.



=== "Next"	
After finishing downsampling and motion correction you can proceed to [Inter-session Alignment](alignment.md)
