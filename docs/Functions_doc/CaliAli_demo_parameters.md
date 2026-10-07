### CaliAli_demo_parameters {#CaliAli_demo_parameters}

#### Syntax
```matlab
function params=CaliAli_demo_parameters()
```

#### Description
CaliAli_demo_parameters: Define demo parameters for CaliAli processing pipeline.

This function initializes and returns a structure containing default parameters
for data preprocessing, motion correction, inter-session alignment, and neuronal
extraction using CNMF-E.

##### Function Inputs:
None

##### Function Outputs:
| Parameter Name | Type    | Description             |
|---------------|---------|-------------------------|
| params        | Structure | All default parameters for CaliAli processing. |

##### Example usage:
```matlab
CaliAli_Options = CaliAli_demo_parameters();
```
# Parameters

#### 📌 Data Preprocessing Parameters
| Parameter Name | Value | Description |
|------------------------------------|-------|-------------|
| `gSig` | `[] (auto)` | Gaussian filter size for neurons (pixels); defaults to `5 / spatial_ds` |
| `sf` | `10` | Frame rate (fps) |
| `BVsize` | `[]` | Size of blood vessels (pixels) \[min diameter, max diameter\]. Default is calculated based on `gSig`. |
| `spatial_ds` | `2` | Spatial downsampling factor |
| `temporal_ds` | `1` | Temporal downsampling factor |
| `neuron_enhance`   | `true` | Enhance neurons using MIN1PIPE background subtraction |
| `noise_scale` | `true` | Scale noise for each pixel |
| `detrend` | `1` | Detrending window (seconds). `0` = no detrending |
| `file_extension` | `'avi'` | If a folder is selected instead of a single video file, concatenate all videos with the specified file extension within that folder. |
| `force_non_negative` | `1` | Clip negative pixel values after preprocessing |
| `force_non_negative_tolerance` | `20` | Amount added before clipping, so negative noise down to `-20` is kept |
| `batch_sz` | `'auto'` | Frames loaded at a time: `'auto'` sizes it from free memory, `'all_frames'` loads the whole recording, `'per_session'` uses one batch per session, or give a number of frames. See [Low-Memory Processing](../Low_memory.md). |

####📌 Motion Correction Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `do_non_rigid` | `false` | Perform non-rigid motion correction? |
| `non_rigid_levels` | `1` | Non-rigid grid levels: 1 = 3×3, each extra level adds a finer grid |
| `reference_projection_rigid` | `'BV'` | Use blood vessels as reference for rigid correction |

#### 📌 Inter-session Alignment Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `projections` | `'BV+neuron'` | Use both blood vessels and neurons for alignment |
| `final_neurons` | `false` | Perform an extra neuron alignment iteration? |
| `Force_BV` | `false` | Force blood vessel use even if deemed unusable |

#### 📌 Neuronal Extraction (CNMF-E) Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `memory_size_to_use` | `total_system_memory_GB` | Auto-detected RAM budget (GB). *Default; not set by the demo.* |
| `memory_size_per_patch` | `total_system_memory_GB` | Patch memory allowance (GB). *Default; not set by the demo.* |
| `patch_dims` | `[64, 64]` | Patch dimensions. *Default; not set by the demo.* |
| `with_dendrites` | `true` | Include dendrites in the model |
| `search_method` | `'dilate'` | Search method (`'dilate'` or `'ellipse'`) |
| `spatial_constraints` | `struct('connected', false, 'circular', false)` | Spatial constraints |
| `spatial_algorithm` | `'hals_thresh'` | Spatial extraction algorithm |

#### 📌 Deconvolution Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `deconv_options.method` | `'foopsi'` | Deconvolution method |
| `deconv_options.type` | `'ar1'` | Calcium trace model (`'ar1'` or `'ar2'`) |
| `deconv_options.smin` | `-5` | Minimum spike size |
| `deconv_options.optimize_pars` | `true` | Optimize AR parameters |
| `deconv_options.optimize_b` | `true` | Optimize baseline |
| `deconv_options.max_tau` | `100` | Max decay time (frames) |
#### 📌 Background Modeling Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `background_model` | `'ring'` | Background model. Only `'ring'` is supported; other values are replaced by `'ring'` with a warning. |
| `nb` | `1` | Number of background components. No effect with the ring model. |
| `bg_neuron_factor` | `1.5` | Radius of the background ring, as a multiple of the neuron size `gSiz` (4 × `gSig`) |
| `ring_radius` | `[]` | Will be calculated later |
| `num_neighbors` | `[]` | Number of neighbors for each neuron |
| `bg_ssub` | `2` | Background downsampling factor |

####📌 Merging & Seeding Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `merge_thr` | `0.65` | Merging threshold |
| `method_dist` | `'max'` | Distance calculation method |
| `dmin` | `5` | Minimum distance between neurons |
| `merge_thr_spatial` | `[0.8, 0.4, -inf]` | Spatial merging threshold |
| `min_corr` | `0.2` | Minimum correlation for seeding |
| `min_pnr` | `4` | Minimum peak-to-noise ratio for seeding |
