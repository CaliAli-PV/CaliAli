# CaliAli Parameters Overview

This page lists the **CaliAli parameters** you are most likely to set, their **default values**, a brief **description**, and guidance on how to choose them. Each parameter is set once and applies to every step that uses it; see [Parameter settings](Parameters.md#per-step) to change one for a single step.

---

## **📌 Parameter Table**

### **🔹 General Parameters**

| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `gSig`             | `[] (auto)`  | Neuron filter size in pixels | Defaults to `5 / spatial_ds`. Override when neuron diameters differ significantly from 5 px. Use [NeuronSize_app](Functions_doc/NeuronSize_app.md) for fine tuning.|
| `sf`               | `10`         | Frame rate (fps) | Set to match the acquisition frame rate. |
| `input_files`       | `[]`         | Paths to input video files | Leave empty to manually select files. |
| `output_files`      | `[]`         | Paths to output video files | Leave empty for default naming (recommended). |
| `batch_sz`         | `'auto'` | **Automatic chunking for large sessions**: `'auto'`, a number of frames, `'all_frames'` or `'per_session'` | Keep `'auto'`; see [Low-Memory Processing](Low_memory.md) for the other options. |

---

### **🔹 Downsampling Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `BVsize`           | `[]`         | Size of blood vessels in pixels [min, max] | Leave empty to automatically calculate based on gSig or use [BV_app](Functions_doc/BV_app.md) (recommended).|
| `spatial_ds`       | `1`          | Spatial downsampling factor | Increase for faster processing, decrease for higher resolution. |
| `temporal_ds`      | `1`          | Temporal downsampling factor | Increase only if memory constraints prevent full processing. |
| `file_extension`    | `'avi'`      | File extension for processed videos organized in folders | Used when sessions are split into multiple files. :material-information-outline:{ title="For example, data acquired with the UCLA Miniscope is often divided into multiple .avi videos. Instead of selecting individual .avi files, you can choose the entire folder so CaliAli finds matching files, treats them as one session, and concatenates them into a single .mat file." } |
| `output_class`     | `'uint16'`   | Datatype used to store the videos: `'uint8'`, `'uint16'` or `'uint32'` | Keep the default; see [Bit depth](Downsampling.md#output-class). |
| `repair_defects`   | `true`       | Find and repair dead pixels, dropped frames and padded borders | Keep enabled; see [Camera defects](Downsampling.md#defects). |
| `repair_borders`   | `true`       | Remove constant borders at the frame edge | Keep enabled unless the border is real data. |
| `dead_pixel_factor` | `0.1`       | Sensitivity of the dead-pixel check | Raise if dead pixels are missed; lower if normal pixels are flagged. |

---

### **🔹 Preprocessing Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `neuron_enhance`   | `true`       | Use MIN1PIPE background subtraction | Keep enabled unless signal loss is observed during preprocessing. |
| `noise_scale`      | `true`       | Enable noise scaling per pixel | Keep enabled unless signal loss is observed during preprocessing. |
| `detrend`         | `1`          | Detrending window (seconds), 0 = no detrending | Set to the duration of calcium transients in seconds. |
| `median_filtering` | `[]`         | Median filter window `[rows, cols]` applied per frame | Enable when noise scaling creates hot pixels near vignetted borders; `[3, 3]` is a good starting point. |
| `force_non_negative` | `1`        | Clip negative pixel values after preprocessing | Keep enabled. |
| `force_non_negative_tolerance` | `20` | Amount added to every pixel before clipping, so small negative noise (down to minus this value) is kept | Increase only if you observe residual bias in dark regions. |
| `remove_BV`        | `false`      | Mask out blood vessels in the preprocessed video and neuron projection | Enable only if blood vessels are picked up as neurons. |
| `fastPNR`          | `false`      | Skip the correlation image when calculating projections (experimental) | Keep the default. |

---

### **🔹 Motion Correction Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `reference_projection_rigid` | `'BV'`  | Reference projection for rigid correction: `'BV'` or `'neuron'` | Choose `'neuron'` if blood vessels are not suitable. |
| `do_non_rigid`      | `false`      | Perform non-rigid motion correction | Enable only if parts of the field of view still drift after rigid correction. See [Non-rigid motion correction](Motion_correction.md#non-rigid). |
| `non_rigid_levels`  | `1`          | Number of non-rigid grid levels (3×3, then 4×4, 5×5, …) | Increase for finer correction; each level adds one registration pass. |
| `non_rigid_highpass_sigma` | `6` | Size, in pixels, of the filter applied to the image that non-rigid correction registers on | Keep the default. |

---

### **🔹 Inter-Session Alignment Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `do_alignment_translation`      | `true`       | Perform inter-session translation| Always true unless sessions were pre-aligned. If do_alignment_non_rigid is also false, videos will be concatenated without registration. |
| `do_alignment_non_rigid`      | `true`       | Perform inter-session alignment | Always true unless sessions were pre-aligned or non-rigid alignment is not necessary. If do_alignment_translation is also false, videos will be concatenated without registration. |
| `projections`       | `'BV+neuron'` | Projection used for alignment: `'BV'`, `'neuron'` or `'BV+neuron'` (case-sensitive) | By default use both blood vessels and neurons. :material-information-outline:{ title="CaliAli automatically falls back to neuron-only registration if vessels are unreliable; set Force_BV = true to enforce blood-vessel alignment." } |
| `final_neurons`     | `false`          | Use an additional alignment iteration based on neurons | Enable if session registration was inaccurate. Often not necessary |
| `Force_BV`         | `0`          | Force BV alignment even if stability score is low | Sometimes BV stability score may be low as results of a debris in the FOV. Setting this parameter to true would ensure that BV are used for registration |
| `same_ses_id`      | `[]`         | Which input files belong to the same recording session, one number per file in the order the files are given (e.g. `[1, 1, 2, 2]`) | Leave empty when each file is a different session. Set it when one session was split into several files; see [Split sessions](Processing_split_data.md). |

---

## **📌 CNMF-E Parameters Overview**

### **🔹 Memory and Patch Processing Parameters**
| Parameter Name           | Default Value | Description | How to Choose |
|--------------------------|--------------|-------------|--------------|
| `memory_size_to_use`     | `total_system_memory_GB` (auto) | Total available memory for computation | Override when you want MATLAB to use less than the detected RAM. |
| `memory_size_per_patch`  | `total_system_memory_GB` (auto) | Memory allocated per patch | Defaults to the detected RAM so patching adapts to your hardware; reduce if you need smaller tiles. |
| `patch_dims`            | `[64, 64]`   | Dimensions of patches | Larger patches improve accuracy but increase computation time and memory consumption. :material-information-outline:{ title="Using more or larger patches also increases memory usage, so scale cautiously." } |
| `w_overlap_fraction`   | `0.5`        | Patch overlap as a fraction of the patch size | Increase if you detect edge artifacts. |
| `w_overlap`            | `[]` (half the patch size) | Patch overlap width in pixels | Leave empty so it follows `w_overlap_fraction`; set a number only to fix the overlap in pixels. |
| `use_parallel`         | `true`       | Run extraction on parallel workers (`true` or `false`) | Set to `false` if parallel workers run out of memory. |

---

### **🔹 Initialization Parameters**
| Parameter Name  | Default Value | Description | How to Choose |
|----------------|--------------|-------------|--------------|
| `min_corr`    | `0.1`        | Minimum correlation for neuron seeding | Usually controlled via `CaliAli_set_initialization_parameters(CaliAli_options)`. :material-information-outline:{ title="Raise the threshold to suppress non-neuronal detections; lower it to recover dim neurons when configuring manually. Use Check_initialization_parameters(CaliAli_options) to preview how many seeds pass." } |
| `min_pnr`     | `6`          | Minimum peak-to-noise ratio for seeding | Same as `min_corr`. |
| `min_pixel`   | `[]`         | Minimum pixel area for neurons | Automatically calculated based on gSig. |

---

### **🔹 Spatial Parameters**
| Parameter Name        | Default Value | Description | How to Choose |
|-----------------------|--------------|-------------|--------------|
| `with_dendrites`     | `true`       | Adjusts the size of the area searched around each neuron (`true` or `false`) | Keep `true`. It does not decide the shape of the footprints; `search_method` does. |
| `search_method`      | `'dilate'`   | How the area searched for each neuron's footprint is defined: `'dilate'` grows it from the current footprint, `'ellipse'` limits it to an ellipse around the neuron | Keep `'dilate'` so dendrites and irregular shapes are kept; use `'ellipse'` only if you want compact, round footprints. |
| `spatial_constraints` | `struct('connected', false, 'circular', false)` | Constraints for spatial filtering | Always disable for better CNMF convergence and dendrite identification. |
| `spatial_algorithm`  | `'hals_thresh'` | Algorithm for spatial extraction | Use default unless alternative extraction methods are needed. |

---

### **🔹 Temporal Parameters**
| Parameter Name    | Default Value | Description | How to Choose |
|-------------------|--------------|-------------|--------------|
| `deconv_flag`    | `true`       | Enable deconvolution | Keep enabled. If `false`, the traces are not deconvolved, during the iterations or at the end. |
| `deconv_options` | `struct('type', 'ar1', 'method', 'foopsi', 'smin', -5, 'optimize_pars', true, 'optimize_b', true, 'max_tau', 100)` | Deconvolution used during the CNMF iterations | Keep the default. |
| `final_deconv_options` | `struct('method', 'foopsi', 'type', 'ar2', 'smin', -5)` | Deconvolution of the final traces, after the CNMF iterations and after [manually_update_residuals](Functions_doc/manually_update_residuals.md#manually_update_residuals) | Keep the default. `smin` is the minimum event size in noise units (−5 = 5 × noise). |

---

### **🔹 Background Parameters**
| Parameter Name    | Default Value | Description | How to Choose |
|-------------------|--------------|-------------|--------------|
| `background_model` | `'ring'`    | Background model | Only `'ring'` is supported; any other value is replaced by `'ring'` with a warning. |

| `bg_neuron_factor` | `1.5`       | Radius of the background ring, as a multiple of the neuron size (`gSiz`) | Keep the default; adjust `gSig` instead. |
| `bg_ssub`          | `2`         | Spatial downsampling of the background estimate, for speed | Keep the default. |
---

### **🔹 Merging Parameters**  
| Parameter Name       | Default Value | Description | How to Choose |  
|----------------------|--------------|-------------|--------------|  
| `merge_thr`         | `0.65`       | Merge neurons closer than `dmin` pixels whose calcium traces correlate above this value | Raise to merge less often; lower if the same neuron is still split into nearby duplicates. |
| `dmin`              | `5`          | Maximum distance (pixels) between two neurons for merging with `merge_thr` | Increase if duplicates of the same neuron lie further apart. |
| `merge_thr_spatial` | `[0.8, 0.4, -inf]` | Merge components with highly correlated spatial shapes (`corr=0.8`), moderate temporal correlations of calcium activities (`corr=0.4`), and disregard spikes correlations (`corr=-inf`). | Increase the spatial correlation threshold when you need stricter merging so only very similar components combine. :material-information-outline:{ title="Higher correlation thresholds reduce false merges by requiring components to be more alike." } |  
