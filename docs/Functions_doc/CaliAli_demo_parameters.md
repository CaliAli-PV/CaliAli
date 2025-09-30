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
| `gSig` | `2.5` | Gaussian filter size for neurons (pixels) |
| `sf` | `10` | Frame rate (fps) |
| `BVsize` | `[]` | Size of blood vessels (pixels) \[min diameter, max diameter\]. Default is calculated based on `gSig`. |
| `spatial_ds` | `1` | Spatial downsampling factor |
| `temporal_ds` | `1` | Temporal downsampling factor |
| `neuron_enhance`   | `true` | Enhance neurons using MIN1PIE background subtraction |
| `noise_scale` | `true` | Scale noise for each pixel |
| `detrend` | `1` | Detrending window (seconds). `0` = no detrending |
| `file_extension` | `'avi'` | If a folder is selected instead of a single video file, concatenate all videos with the specified file extension within that folder. |

####📌 Motion Correction Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `do_non_rigid` | `false` | Perform non-rigid motion correction? |
| `reference_projection_rigid` | `'BV'` | Use blood vessels as reference for rigid correction |
| `non_rigid_pyramid` | `{'BV', 'BV', 'neuron'}` | Multi-level registration pyramid |
| `non_rigid_batch_size` | `[20, 60]` | Frame range for parallel processing |

#### 📌 Inter-session Alignment Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `projections` | `'BV+neuron'` | Use both blood vessels and neurons for alignment |
| `final_neurons` | `0` | Perform an extra neuron alignment iteration? |
| `Force_BV` | `false` | Force blood vessel use even if deemed unusable |

#### 📌 Neuronal Extraction (CNMF-E) Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `frames_per_batch` | `0` | Number of frames per batch. `0` = process each session as a single batch |
| `memory_size_to_use` | `256` | Memory allowed for MATLAB (GB) |
| `memory_size_per_patch` | `16` | Memory for each patch (GB) |
| `patch_dims` | `[64, 64]` | Patch dimensions |
| `with_dendrites` | `true` | Include dendrites in the model |
| `search_method` | `'dilate'` | Search method (`'dilate'` or `'ellipse'`) |
| `spatial_constraints` | `struct('connected', false, 'circular', false)` | Spatial constraints |
| `spatial_algorithm` | `'hals_thresh'` | Spatial extraction algorithm |

#### 📌 Deconvolution Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `deconv_options.type` | `'ar1'` | Calcium trace model (`'ar1'` or `'ar2'`) |
| `deconv_options.method` | `'foopsi'` | Deconvolution method |
| `deconv_options.smin` | `-5` | Minimum spike size |
| `deconv_options.optimize_pars` | `true` | Optimize AR parameters |
| `deconv_options.optimize_b` | `true` | Optimize baseline |
| `deconv_options.max_tau` | `100` | Max decay time (frames) |

#### 📌 Background Modeling Parameters
| Parameter Name | Value | Description |
|---------------|-------|-------------|
| `background_model` | `'ring'` | Background model |
| `nb` | `1` | Number of background components |
| `bg_neuron_factor` | `1.5` | Background-neuron interaction factor |
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
