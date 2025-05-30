# Version History <a id="vh"></a> 


## CaliAli 1.2.2 Release Notes

**May 30th 2025**

- The `do_alignment` flag has been split into `do_alignment_translation` and `do_alignment_non_rigid`, so you can perform either alignment operation—or skip both if both flags are set to false—replicating the original `do_alignment` behavior when neither is enabled.
- Introduced the `force_non_negative_tolerance` parameter. Previously, any negative pixel values produced after detrending were automatically trimmed; now, small negative values are permitted.
- Substantially improved the efficiency of the `create_similarity_matrix` function used to compare extraction similarities across CNMF iterations.
- Optimized `play_movie` for more efficient playback handling.


#### CaliAli 1.2.1 Release Notes

**April 16th 2025**

- Added documentation for processing split calcium imaging data files, including support for multiple video segments per session and TIFF files.
- Fixed a bug where the text progress bar did not display the final update.
- Fixed a bug where traces were not correctly displayed in `postprocessing_app`.
- Disabled batch processing in `v2uint16` and `v2uint8` due to compatibility issues on some operating systems.
- Fixed a bug where the background component was not correctly handled in batch mode when using the SVG model.
- Improved data handling when saving concatenated files, making the new code significantly faster.

---


#### CaliAli 1.2 Release Notes

**February 7th 2025**

This update focuses on increasing the modularity of the CaliAli pipeline by restructuring how parameters and functions are handled. A central CaliAli_options structure now consolidates all settings required for video processing, enabling each module to operate more independently. This refactoring lays groundwork for future support of multiple calcium imaging data types (including both 2P and 1P) and specialized tools for dendritic signal extraction.

Because of these significant changes, the previous workflow used to analyze data is no longer compatible, and older procedures will not work in the updated environment.

###### Other Changes

| File / Group | Change Summary |
|--------------|----------------|
| Downsample & ScanImageTiffReader (Downsample/…) | Introduced CaliAli_downsample and batchConvertVideos; removed legacy Inscopix, AVI, temporal, and TIFF downsampling scripts; updated ISXD2h5 to omit downsampling; and added a new ScanImageTiffReader package with associated helpers and mex compilation adjustments for cpp‑tiff usage. |
| Motion Correction (Vessel_MC and other codes) | Added new functions CaliAli_motion_correction and Rigid_mc; removed outdated MC_Batch and motion_correct_PV; introduced Non_rigid_mc and refinements in vessel–focused correction routines. |
| Other_codes (Utilities and Experimental) | Added utilities for loading (CaliAli_load), saving (CaliAli_save, CaliAli_save_chunk), updating parameters (CaliAli_update_parameters, update_CaliAli_options), and various helpers (catpad_centered, concat_nan_centered, getSystemMemory, v2uint16/v2uint8 enhancements) with widespread improvements in memory management and file concatenation. |
| Postprocessing | Modified functions for residual updates and manual corrections (get_seed, manually_update_residuals, mouse_click, postprocessDeconvolvedTraces, postprocessing_app, update_residual_custom_seeds) with refined parameter sourcing and GUI improvements. |
| Documentation (README.md & docs/…) | Updated online documentation links; added numerous documentation files for new/updated functions (e.g. CNMFE_parameters, CaliAli_cnmfe, CaliAli_downsample, motion correction, postprocessing, etc.), enhancing details on syntax, inputs, outputs, and usage. |

---

#### CaliAli 1.0.1 Release Notes
**April 22nd 2024**

- Introduced a new app for determining optimal blood vessel (BV) size.
- Removed unnecessary or deprecated functions.
- Several improvements to the documentation.

[Full Changelog](https://github.com/CaliAli-PV/CaliAli/compare/v1.0...v1.0.1) on GitHub.

#### CaliAli Stable Version 1.0 Release Notes
**April 19th 2024**

We are excited to announce the first stable version of CaliAli, featuring significant enhancements and improvements. Below are the key changes in this release:

***Changes***:

- **Full Online Documentation:** Access comprehensive documentation to guide you through using CaliAli efficiently.

- **Optimized Computational Performance:** CaliAli is now optimized for low memory requirements, ensuring smoother and more efficient processing.

- **Improved Session Analysis:** Analyze individual sessions and perform multisession concatenation seamlessly.

- **Enhanced Blood Vessel (BV) Extraction:** Minimized vignetting artifacts for improved accuracy in BV extraction.

- **New BV Stability Metric:** Evaluate tracking performance with a new stability metric integrated into BV extraction.

- **Bug Fixes in GUIs:** Addressed several bugs in the graphical user interfaces (GUIs) for improved usability.

- **Enhanced Inter-Session Alignment:** Further improvements to the inter-session alignment module for precise video session alignment.

[Full Changelog](https://github.com/CaliAli-PV/CaliAli/compare/Biorxiv-Version...main) on GitHub.

---

#### CaliAli Beta Release 1.0-beta 
**May 19th 2023**

The first beta release of CaliAli is now available, offering advanced capabilities for extracting neural signals from one-photon calcium imaging data in free-moving conditions.

For details, refer to the [BioRxiv preprint](https://www.biorxiv.org/content/10.1101/2023.05.19.540935v1).

Explore CaliAli to analyze calcium imaging data with accuracy and efficiency, shaping the future of neural signal extraction in neuroscience research.

