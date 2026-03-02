# Version History <a id="vh"></a> 

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
