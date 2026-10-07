# Version History <a id="vh"></a> 

## CaliAli 1.5.0 Release Notes — September 2026

- **Bright signals are no longer clipped**: Downsampling capped 12- and 16-bit videos at 8-bit, so all bright signals ended up with the same value. CaliAli now keeps the original brightness range; see [Bit depth](Downsampling.md#output-class).
- **Dead pixels and dropped frames**: A few dead pixels on the camera could make motion correction fail without warning, and dropped frames were never detected. CaliAli now finds and repairs both automatically; see [Camera defects](Downsampling.md#defects).
- **Videos motion-corrected in other software**: These files can carry padded borders and differ in size between sessions, which corrupted the alignment. CaliAli now matches the session sizes and removes borders that are the same in every frame; borders that change from frame to frame are reported so you can crop them; see [Can I use CaImAn or Suite2p for motion correction?](FAQ.md#external-mc) in the FAQ.
- **Less field of view lost**: Dark pixels near the edge of the frame were mistaken for empty borders and cropped away. CaliAli now crops only real borders.
- **New non-rigid motion correction**: The previous non-rigid method was never fully validated and in many cases created alignment artifacts. It has been replaced by the NoRMCorre engine and is still off by default; see [Non-rigid motion correction](Motion_correction.md#non-rigid) for how to turn it on.
- **Fewer out-of-memory crashes**: The automatic batch size and the number of parallel workers ignored how much memory was actually free. Both now adjust to the free memory; see [Low-Memory Processing](Low_memory.md).
- **Interrupted and repeated runs**: Re-running a step on a finished folder crashed, resuming after an interruption skipped the final cropping step, and small output files could be deleted as if they were broken. All three are fixed.
- **Your MATLAB workspace**: Running extraction erased the variables in your workspace. It no longer touches your workspace.
- **Correct residuals**: The residual movie in `play_movie` and the residual image used to find missed neurons removed too much signal. Both are now correct.
- **Sessions that differ in brightness**: During neuron extraction, one chunk of frames could hold the end of one session and the start of the next, and when the two sessions differed in brightness most neurons were lost. Chunks now never span two sessions, and the residual of each chunk is centred on its own brightness; see [Low-Memory Processing](Low_memory.md).
- **Memory settings reach neuron extraction**: With `batch_sz = 'all_frames'`, neuron extraction still ran one session at a time, and with `'auto'` its chunk size was decided during alignment. Extraction now uses the setting as you gave it, and fixes its chunks when it starts, so a change in free memory part way through cannot change them.
- **Detrending off**: With `detrend = 0`, extraction stopped with an error after the main iterations. It now completes.
- **Settings go where you put them**: A setting made for a single step was silently overwritten, and passing several settings at once to `CaliAli_parameters` gave an error. Both now work; see [Setting CaliAli Parameters](Parameters.md#per-step).
- **One downsampling function**: Two downsampling functions gave different results on the same video. `CaliAli_downsample()` now handles every case, and `CaliAli_downsample_batch()` still works; see [Downsampling](Downsampling.md).
- **Clearer memory settings**: `batch_sz = 0` meant different things in different steps. You can now choose `'auto'`, `'all_frames'` or `'per_session'`, and `0` still works as before; see [Low-Memory Processing](Low_memory.md).

!!! warning "If you have existing scripts"
    - `background_model`: `'svd'` and `'nmf'` were built for two-photon data and crashed during extraction. CaliAli now warns you and uses `'ring'`; see [Extraction](extraction.md#background-model).
    - `output_class`: values other than `'uint8'`, `'uint16'` or `'uint32'` crashed late in extraction. They are now rejected as soon as you set them; see [Bit depth](Downsampling.md#output-class).

---

## CaliAli 1.4.8 Release Notes — March 2026

- **Easier processing for large datasets**: Added batch downsampling support so long recordings can be processed in smaller chunks with lower memory risk.
- **Smoother scripted workflows**: Improved handling of user-provided file lists so automated pipelines are less likely to open unexpected file-selection windows.
- **More reliable alignment outputs**: Added stronger frame-integrity checks to catch incomplete or corrupted outputs earlier.
- **Better recovery behavior**: Some partially written intermediate files are now detected and regenerated automatically.
- **CNMF-E startup improvements**: Fixed a demo-data crash and improved input handling when launching extraction.
- **Quality-of-life updates**: Added `add_paths()` helper to quickly include CaliAli folders in the MATLAB path.

---

## CaliAli 1.4.6 Release Notes — November 2025

- **Parallel processing restored**: A bug in 1.4.5 forced single-core execution; multi-core execution is back.
- **Memory sizing fixes**: Batch sizing during CNMF iterations is now more stable.
- **Patch-size migration fix**: For 1.4.5 option files, run `CaliAli_update_parameters('patch_dims',[64,64])` and resave before relaunching jobs.
- **Full 16-bit storage**: Video data are now stored as `uint16` to preserve dynamic range (with larger file size).

---

## CaliAli 1.4.5 Release Notes — October 2025

- **Auto sizing improvements**: `batch_sz` accepts `'auto'`, and `gSig` defaults to `5 / spatial_ds`.
- **Clearer logs**: Status and warnings were improved with colored command-window output.
- **Preprocessing updates**: Improved non-negativity handling and optional median denoising.
- **Robust alignment/file handling**: Better handling of frame-size changes, chunk frame counts, and natural sorting.
- **Initialization preview**: Added [`Check_initialization_parameters`](Functions_doc/Check_initialization_parameters.md).
- **Additional bug fixes**: Motion-correction input handling and parameter-selection stability improvements.
- **Enhanced demo**: Updated `Demo_pipeline.mlx` with synthetic full-resolution examples.

---

## CaliAli 1.4 Release Notes — September 26th 2025

- **Automatic session chunking**: `batch_sz` splits oversized sessions across motion correction, alignment, and projection steps. See [Processing Large Sessions](Low_memory.md).
- **Batch helpers**: Added `create_batch_list()` and `pre_allocate_outputs()`.
- **Memory/resilience tweaks**: Improved fallback behavior and lighter spatial updates.
- **Interactive cropping**: Added `CaliAli_crop()`.
- **Projection refinements**: Better chunk aggregation consistency.
- **Migration note**: `batch_sz = 0` preserves legacy behavior.

---

## Older Versions (Archived)

??? info "CaliAli 1.3 — August 2025"
    - Introduced low-memory mode for large sessions.
    - Simplified BV detection pipeline.
    - Added interactive parameter-selection demos and app updates.

??? info "CaliAli 1.2.2 / 1.2.1 / 1.2 — February to May 2025"
    - Split alignment flags into translation and non-rigid controls.
    - Added `force_non_negative_tolerance`.
    - Major parameter/pipeline modularization in v1.2.
    - Added documentation for split-session processing and multiple bug fixes.

??? info "CaliAli 1.0.1 / 1.0 / 1.0-beta — 2023 to 2024"
    - First stable releases and core pipeline stabilization.
    - Documentation expansion and GUI fixes.
    - Initial publication release aligned with the BioRxiv preprint.
