# Version History <a id="vh"></a> 

## CaliAli 1.5.0 Release Notes — September 2026

**Changes that affect existing scripts**

- **One downsampler.** `CaliAli_downsample()` is now the chunked implementation. The old one loaded a whole recording and cast it to `uint8`, which silently clipped every value above 254 in `uint16` and floating-point data. `CaliAli_downsample_batch()` still runs and warns.
- **Ring is the only background model.** `background_model` set to `svd` or `nmf` now warns and uses `ring`. Those models came from CNMF-E, were written for two-photon data, and were never implemented for the batched extraction CaliAli runs.
- **`output_class` accepts unsigned integers only.** `single` and `double` are refused when you set them, rather than failing several stages later.

**Data no longer silently lost**

- **Recordings keep their dynamic range.** `uint16` is the default; nothing is clipped to 255 on the way in.
- **Dropped frames are actually detected.** The test for them could never fire, because a `+1` added upstream meant a blank frame never read as blank. Blank frames are now found and interpolated.
- **Dead pixels and leftover borders are repaired** before anything registers against them. A pixel that never changes does not move with the tissue, and motion correction locks onto whatever does not move: three dead pixels were enough to stop it working. Controlled by `repair_defects`.
- **Your workspace is left alone.** Extraction no longer clears variables from the base workspace.

**Alignment and motion correction**

- **Non-rigid correction works again.** It previously required the Computer Vision Toolbox, which not every licence includes; without it the stage failed with an error that pointed somewhere else entirely. It now uses NoRMCorre's grid mode. Still off by default — see [Motion Correction](Motion_correction.md) for when it is worth enabling.
- **`non_rigid_levels`** sets how finely it corrects, one level by default.
- **Sessions of different sizes align correctly**, including recordings motion-corrected outside CaliAli that carry no record of how they were cropped.

**Settings**

- **`batch_sz` says what it means**: `'auto'`, `'all_frames'` or `'per_session'`, instead of a `0` that meant different things in different stages. Numbers still work, and so does `0`.
- **A setting on one module stays on that module.** `opt.motion_correction.batch_sz = 250` previously leaked to every stage or was discarded; it now applies where you put it.
- **Patch padding follows the patch size** rather than a fixed 10 pixels.

**Fixes**

- Re-running the pipeline over a folder that is already processed no longer fails with `Unrecognized function or variable 'out'`.
- Videos are read in natural order, so `2.avi` comes before `10.avi`.
- `ISXD2h5` no longer fails on an undefined variable when reading Inscopix files.

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
