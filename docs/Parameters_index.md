# CaliAli Parameters Overview

This table lists all **CaliAli parameters**, their **default values**, a brief **description**, and guidance on how to choose them.

---

## **📌 Parameter Table**

### **🔹 General Parameters**

| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `gSig`             | `[] (auto)`  | Neuron filter size in pixels | Defaults to `5 / spatial_ds`. Override when your data are anisotropic or when neuron diameters differ significantly from 5 px. Use [NeuronSize_app](Functions_doc/NeuronSize_app.md) for fine tuning.|
| `sf`               | `10`         | Frame rate (fps) | Set to match the acquisition frame rate. |
| `input_files`       | `[]`         | Paths to input video files | Leave empty to manually select files. |
| `output_files`      | `[]`         | Paths to output video files | Leave empty for default naming (recommended). |
| `batch_sz`         | `'auto'` (demo) / `0` | **Automatic chunking for large sessions** (frames per chunk, 0 = disable) | Auto-estimates chunk size from available RAM; set a numeric value or `0` to override. :material-information-outline:{ title="See the Low_memory guide for recommended overrides when the heuristic over- or under-allocates." } |

---

### **🔹 Downsampling Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `BVsize`           | `[]`         | Size of blood vessels in pixels [min, max] | Leave empty to automatically calculate based on gSig or use [BV_app](Functions_doc/BV_app.md) (recommended).|
| `spatial_ds`       | `1`          | Spatial downsampling factor | Increase for faster processing, decrease for higher resolution. |
| `temporal_ds`      | `1`          | Temporal downsampling factor | Increase only if memory constraints prevent full processing. |
| `file_extension`    | `'avi'`      | File extension for processed videos organized in folders | Used when sessions are split into multiple files. :material-information-outline:{ title="For example, data acquired with the UCLA Miniscope is often divided into multiple .avi videos. Instead of selecting individual .avi files, you can choose the entire folder so CaliAli finds matching files, treats them as one session, and concatenates them into a single .mat file." } |
| `force_non_negative ` | `1 `| Enforce non-negative pixels during preprocessing | When enabled, values are lifted and clipped within `CaliAli_remove_background` after noise scaling. |
| `force_non_negative_tolerance`  | `13` | Non-negative tolerance threshold | Gap added before clipping; increase only if you observe residual bias in dark regions. |

---

### **🔹 Preprocessing Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `neuron_enhance`   | `true`       | Use MIN1PIE background subtraction | Keep enabled unless signal loss is observed during preprocessing. |
| `noise_scale`      | `true`       | Enable noise scaling per pixel | Keep enabled unless signal loss is observed during preprocessing. |
| `detrend`         | `1`          | Detrending window (seconds), 0 = no detrending | Set to the duration of calcium transients in seconds. |

---

### **🔹 Motion Correction Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `reference_projection_rigid` | `'BV'`  | Reference projection for rigid correction | Choose `neuron` if blood vessels are not suitable. |
| `do_non_rigid`      | `false`      | Perform non-rigid motion correction | Enable only after confirming rigid correction was insufficient. :material-information-outline:{ title="The current non-rigid module is experimental and may introduce field-of-view artifacts; an updated implementation is planned." } |
| `non_rigid_pyramid` | `{'BV','neuron','neuron'}` | Multi-level registration pyramid for non-rigid correction | Use default unless BV is unavailable. |
| `non_rigid_batch_size` | `[20,60]` | Batch size range for non-rigid correction, CaliAli will optimize within this range. | Set as `[2 x sf, 6 x sf]`. |

---

### **🔹 Inter-Session Alignment Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `do_alignment_translation`      | `true`       | Perform inter-session translation| Always true unless sessions were pre-aligned. If do_alignment_non_rigid is also false, videos will be concatenated without registration. |
| `do_alignment_non_rigid`      | `true`       | Perform inter-session alignment | Always true unless sessions were pre-aligned or non-rigid alignment is not necessary. If do_alignment_translation is also false, videos will be concatenated without registration. |
| `projections`       | `'BV+neuron'` | Projection method used for alignment | By default use both blood vessels and neurons. :material-information-outline:{ title="CaliAli automatically falls back to neuron-only registration if vessels are unreliable; set Force_BV = true to enforce blood-vessel alignment." } |
| `final_neurons`     | `false`          | Use an additional alignment iteration based on neurons | Enable if session registration was inaccurate. Often not necessary |
| `Force_BV`         | `0`          | Force BV alignment even if stability score is low | Sometimes BV stability score may be low as results of a debris in the FOV. Setting this parameter to true would ensure that BV are used for registration |

---

## **📌 CNMF-E Parameters Overview**

### **🔹 Memory and Patch Processing Parameters**
| Parameter Name           | Default Value | Description | How to Choose |
|--------------------------|--------------|-------------|--------------|
| `memory_size_to_use`     | `total_system_memory_GB` (auto) | Total available memory for computation | Override when you want MATLAB to use less than the detected RAM. |
| `memory_size_per_patch`  | `total_system_memory_GB` (auto) | Memory allocated per patch | Defaults to the detected RAM so patching adapts to your hardware; reduce if you need smaller tiles. |
| `patch_dims`            | `[64, 64]`   | Dimensions of patches | Larger patches improve accuracy but increase computation time and memory consumption. :material-information-outline:{ title="Using more or larger patches also increases memory usage, so scale cautiously." } |
| `w_overlap`            | `32`         | Patch overlap width | Increase if you detect edge artifacts. |

---

### **🔹 Initialization Parameters**
| Parameter Name  | Default Value | Description | How to Choose |
|----------------|--------------|-------------|--------------|
| `min_corr`    | `0.1`        | Minimum correlation for neuron seeding | Usually controlled via `CaliAli_set_initialization_parameters(CaliAli_options)`. :material-information-outline:{ title="Raise the threshold to suppress non-neuronal detections; lower it to recover dim neurons when configuring manually." } |
| `min_pnr`     | `6`          | Minimum peak-to-noise ratio for seeding | Same as `min_corr`. |
| `min_pixel`   | `[]`         | Minimum pixel area for neurons | Automatically calculated based on gSig. |

---

### **🔹 Spatial Parameters**
| Parameter Name        | Default Value | Description | How to Choose |
|-----------------------|--------------|-------------|--------------|
| `with_dendrites`     | `true`       | Do not assume that signals are circular during extraction | Keep enabled for better CNMF convergence and accurate dendrite detection. :material-information-outline:{ title="Disabling applies a circular kernel that can mislabel dendrites as somas." } |
| `spatial_constraints` | `{'connected': False, 'circular': False}` | Constraints for spatial filtering | Always disable for better CNMF convergence and dendrite identification. |
| `spatial_algorithm`  | `'hals_thresh'` | Algorithm for spatial extraction | Use default unless alternative extraction methods are needed. |

---

### **🔹 Temporal Parameters**
| Parameter Name    | Default Value | Description | How to Choose |
|-------------------|--------------|-------------|--------------|
| `deconv_flag`    | `true`       | Enable deconvolution | Use default if unsure. Enable for better temporal resolution. |
| `deconv_options` | `{'type': 'ar1', 'method': 'foopsi', 'smin': -5, 'optimize_pars': True, 'max_tau': 100}` | Deconvolution settings | Use default parameters to minimize false-positives and computational stability |

### **🔹 Merging Parameters**  
| Parameter Name       | Default Value | Description | How to Choose |  
|----------------------|--------------|-------------|--------------|  
| `merge_thr_spatial` | `[0.8, 0.4, -inf]` | Merge components with highly correlated spatial shapes (`corr=0.8`), moderate temporal correlations of calcium activities (`corr=0.4`), and disregard spikes correlations (`corr=-inf`). | Increase the spatial correlation threshold when you need stricter merging so only very similar components combine. :material-information-outline:{ title="Higher correlation thresholds reduce false merges by requiring components to be more alike." } |  
