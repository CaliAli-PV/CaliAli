# CaliAli Parameters Overview

This table lists all **CaliAli parameters**, their **default values**, a brief **description**, and guidance on how to choose them.

---

## **📌 Parameter Table**

### **🔹 General Parameters**

| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `gSig`             | `2.5`        | Neuron filter size in pixels | Use 1/5 of the neuron diameter in pixels. If unsure, opt for smaller values.|
| `sf`               | `10`         | Frame rate (fps) | Set to match the acquisition frame rate. |
| `input_files`       | `[]`         | Paths to input video files | Leave empty to manually select files. |
| `output_files`      | `[]`         | Paths to output video files | Leave empty for default naming (recommended). |

---

### **🔹 Downsampling Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `BVsize`           | `[]`         | Size of blood vessels in pixels [min, max] | Leave empty to automatically calculate based on gSig or use `BV_app` for optimal selection.|
| `spatial_ds`       | `1`          | Spatial downsampling factor | Increase for faster processing, decrease for higher resolution. |
| `temporal_ds`      | `1`          | Temporal downsampling factor | Increase only if memory constraints prevent full processing. |
| `file_extension`    | `'avi'`      | File extension for processed videos organized in folders | [Used when sessions are split into multiple files.]("For example, data acquired with the UCLA Miniscope is often divided into multiple .avi videos. Instead of selecting individual .avi files, you can choose the entire folder. CaliAli will automatically search for all files matching file_extension within that folder and treat them as segments of the same session. These files will then be concatenated into a single .mat file for streamlined processing.")|
| `force_non_negative ` | `1 `| Enforce non-negative pixels after detrending | Enable to clamp all negative pixel values to zero; disable to allow negatives within the specified tolerance. |
| `force_non_negative_tolerance`  | `20` | Non-negative tolerance threshold | Allows pixel values to remain negative up to this limit before clamping occurs. |

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
| `do_non_rigid`      | `false`      | Perform non-rigid motion correction | [Enable only after confirming rigid correction was insufficient.]("Currently the non-rigid registration module may introduce artifacts to the FOV. We are working on Implementing a more suitable non-rigid registration module") |
| `non_rigid_pyramid` | `{'BV','BV','neuron'}` | Multi-level registration pyramid for non-rigid correction | Use default unless BV is unavailable. |
| `non_rigid_batch_size` | `[20,60]` | Batch size range for non-rigid correction, CaliAli will optimize within this range. | Set as `[2 x sf, 6 x sf]`. |

---

### **🔹 Inter-Session Alignment Parameters**
| Parameter Name       | Default Value | Description | How to Choose |
|----------------------|--------------|-------------|--------------|
| `do_alignment_translation`      | `true`       | Perform inter-session translation| Always true unless sessions were pre-aligned. If do_alignment_non_rigid is also false, videos will be concatenated without registration. |
| `do_alignment_non_rigid`      | `true`       | Perform inter-session alignment | Always true unless sessions were pre-aligned or non-rigid alignment is not necessary. If do_alignment_translation is also false, videos will be concatenated without registration. |
| `projections`       | `'BV+neuron'` | Projection method used for alignment | [By default, use both blood vessels and neurons for registration. If one is unsuitable, choose either BV or neurons.]("CaliAli automatically evaluates the usability of BV and may switch to a neuron-only registration strategy if necessary, even when ‘BV+neurons’ is selected. To enforce the use of BV, set Force_BV to true.")|
| `final_neurons`     | `false`          | Use an additional alignment iteration based on neurons | Enable if session registration was inaccurate. Often not necessary |
| `Force_BV`         | `0`          | Force BV alignment even if stability score is low | Sometimes BV stability score may be low as results of a debris in the FOV. Setting this parameter to true would ensure that BV are used for registration |

---

## **📌 CNMF-E Parameters Overview**

### **🔹 Memory and Patch Processing Parameters**
| Parameter Name           | Default Value | Description | How to Choose |
|--------------------------|--------------|-------------|--------------|
| `memory_size_to_use`     | `total_system_memory_GB` | Total available memory for computation | Adjust based on available RAM. |
| `memory_size_per_patch`  | `16`       | Memory allocated per patch | Adjust based on available RAM and number of patches. |
| `patch_dims`            | `[64, 64]`   | Dimensions of patches | [Larger patches improve accuracy but increase computation time.]("Note that using more patches also increases memory demands."). |
| `w_overlap`            | `32`         | Patch overlap width | Increase if you detect edge artifacts. |
| `batch_sz`         | `0`          | Batch size for alignment, 0 = full session | [By default, the batch size is set to match the duration of each session. This parameter allows you to define batches in terms of the number of frames instead.]("This is particularly useful when sessions are very short (e.g., <1000 frames), making it difficult to resolve neuronal components within each session. It is also helpful when memory constraints prevent processing an entire session at once.") |

---

### **🔹 Initialization Parameters**
| Parameter Name  | Default Value | Description | How to Choose |
|----------------|--------------|-------------|--------------|
| `min_corr`    | `0.1`        | Minimum correlation for neuron seeding | [In most cases, this value is overridden using `CaliAli_set_initialization_parameters(CaliAli_options)`, allowing selection via a GUI. If not using the GUI, increase it to reduce non-neuronal detections or decrease it to detect more neurons.]("Run `CaliAli_set_initialization_parameters(CaliAli_options)` before `CaliAli_cnmfe()` and after alignment. It requires correlation and PNR images, generated during detrending, and can only be used on `_det` labeled videos.") |
| `min_pnr`     | `6`          | Minimum peak-to-noise ratio for seeding | Same as `min_corr`. |
| `min_pixel`   | `[]`         | Minimum pixel area for neurons | Automatically calculated based on gSig. |

---

### **🔹 Spatial Parameters**
| Parameter Name        | Default Value | Description | How to Choose |
|-----------------------|--------------|-------------|--------------|
| `with_dendrites`     | `true`       | Do not assume that signals are circular during extraction |[Always enable for better CNMF convergence and proper dendrite detection.]("Disabling this applies a circular kernel filter, which may cause dendrites to appear as neurons, making their removal more difficult.")|
| `spatial_constraints` | `{'connected': False, 'circular': False}` | Constraints for spatial filtering | [Always disable for better CNMF convergence and dendrite identification.] |
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
| `merge_thr_spatial` | `[0.8, 0.4, -inf]` | Merge components with highly correlated spatial shapes (`corr=0.8`), moderate temporal correlations of calcium activities (`corr=0.4`), and disregard spikes correlations (`corr=-inf`). | [Increase spatial correlation threshold for stricter merging.]("Higher values ensure that only very similar spatial components merge, reducing false positives.") |  
