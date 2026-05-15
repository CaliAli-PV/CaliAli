# How `CaliAli_align_sessions` Works

`CaliAli_align_sessions` is the inter-session alignment pipeline used before
CNMF-E extraction. It first creates or reuses one detrended projection file per
session, saved as `*_det.mat`, then estimates inter-session transforms from
stored projections, applies those transforms to the detrended videos, and saves
the concatenated aligned stack as `*_Aligned.mat`.

The entry point is:

```matlab
CaliAli_options = CaliAli_align_sessions(CaliAli_options);
```

If `CaliAli_options.inter_session_alignment.input_files` is empty, the function
opens a file picker for `.mat` files. Otherwise it uses the paths already stored
in the options structure.

## High-Level Pipeline

The main function runs these stages:

1. Parse and complete options with `CaliAli_parameters`.
2. Record the original frame count for each input session.
3. Detrend each session, remove background, calculate projections, and save or
   reuse `*_det.mat` files.
4. Verify the detrended outputs against the original frame counts.
5. Match video sizes across sessions if necessary.
6. Load stored projections from the `*_det.mat` files.
7. Estimate translation alignment.
8. Estimate non-rigid alignment.
9. Optionally run a final neuron-only non-rigid alignment.
10. Evaluate blood-vessel alignment quality and fall back to neuron-based
    alignment if the blood-vessel score is too low.
11. Compute alignment metrics.
12. Apply the final transforms to the full detrended videos and save the
    aligned stack.
13. Save final projections, metrics, and options into the aligned file.

The working flow is:

```text
raw or motion-corrected .mat files
        |
        | record_input_frame_counts
        v
*_det.mat files
        |  Y = detrended/background-corrected video
        |  CaliAli_options.inter_session_alignment.P = projections
        |
        | get_stored_projections
        v
projection table P1
        |
        | sessions_translate
        v
translated projections P2
        |
        | sessions_non_rigid
        v
non-rigid projections P3
        |
        | optional final neuron-only sessions_non_rigid
        v
final transforms
        |
        | apply_transformations
        v
*_Aligned.mat
```

## Important Inputs

The most important fields are in
`CaliAli_options.inter_session_alignment`:

| Field | Purpose |
| --- | --- |
| `input_files` | Input `.mat` files. Each file is expected to contain `Y`, a height x width x frames video. |
| `batch_sz` | Number of frames per processing batch. `0` means whole sessions; `'auto'` uses memory-based sizing. |
| `projections` | Alignment features. Default is `'BV+neuron'`; other paths can use only blood vessels or neurons. |
| `do_alignment_translation` | Enables or disables translation alignment. |
| `do_alignment_non_rigid` | Enables or disables non-rigid alignment. |
| `final_neurons` | Adds one final neuron-only non-rigid pass after the main CaliAli pass. |
| `Force_BV` | Keeps blood-vessel alignment even if the BV stability score is low. |
| `same_ses_id` | Groups input files that belong to the same biological session, useful when sessions were manually split. |

The alignment code also relies on preprocessing fields such as `sf`, `gSig`,
`BVsize`, `preprocessing.detrend`, `preprocessing.noise_scale`,
`preprocessing.neuron_enhance`, `preprocessing.remove_BV`, and
`preprocessing.median_filtering`.

## Stage 1: Options And Input Selection

`CaliAli_align_sessions` starts with:

```matlab
CaliAli_options = CaliAli_parameters(varargin{:});
```

`CaliAli_parameters` accepts either an existing structure or name-value pairs.
It builds the nested option structures for downsampling, preprocessing, motion
correction, inter-session alignment, and CNMF-E. For alignment, the defaults
include:

- `do_alignment_translation = true`
- `do_alignment_non_rigid = true`
- `projections = 'BV+neuron'`
- `final_neurons = 0`
- `Force_BV = 0`
- `batch_sz = 0`

If no alignment input files were provided, the code asks the user to select
`.mat` files with `uipickfiles`.

## Stage 2: Original Frame Checks

Before detrending, `record_input_frame_counts` stores the original number of
frames for each session.

For each input file it:

- resolves the session id, including batch entries of the form
  `{filename, session_id, start_frame, end_frame, output_filename}`;
- resolves the source filename;
- calls `get_data_dimension` to read the size of `Y`;
- stores the frame count in `inter_session_alignment.input_F`;
- stores the source path in `input_file_labels`;
- checks whether the last frame of `Y` is all zeros.

If the last frame is all zeros, the function reports the issue and throws a
`CaliAli:frameCheck` error. This catches a common incomplete-write failure mode.

## Stage 3: Detrending, Background Removal, And Projection Files

This stage is handled by `detrend_batch_and_calculate_projections`.

### Batch List Creation

`create_batch_list` converts the input files into batch-aware entries:

```matlab
{filename, session_id, start_frame, end_frame, output_filename}
```

The `output_filename` is the corresponding `*_det.mat` path. If `batch_sz` is
`0`, the file is processed as one chunk. If `batch_sz` is `'auto'`,
`compute_auto_batch_size` estimates a batch size from RAM and frame dimensions.

### Reusing Existing `*_det.mat` Files

`pre_allocate_outputs` decides which batches need processing.

- If the `*_det.mat` output does not exist, it marks the file for processing.
- If a batched output does not exist, it pre-allocates `Y` on disk with the full
  expected size.
- If a `*_det.mat` output already exists, it reuses that file and skips
  recalculation.
- Before reuse, `remove_corrupted_output` deletes an existing output if the file
  cannot be read or if its last `Y` frame is all zeros.

This is the main reuse mechanism. Projection calculation is expensive, so an
existing valid `*_det.mat` prevents unnecessary recomputation.

### Per-Session Processing

For every batch that needs processing, the code loads `Y` with `CaliAli_load`
and calls:

```matlab
[Y, P, range, opt] = get_projections_and_detrend(Y, opt_g);
```

`get_projections_and_detrend` does the core preprocessing:

1. Computes the median image `M = median(Y, 3)`.
2. Extracts a blood-vessel projection with `CaliAli_get_blood_vessels`.
3. Removes background with `CaliAli_remove_background`.
4. Optionally suppresses blood-vessel regions in the video with `remove_BV`.
5. Calculates neuron and PNR projections.
6. Clips the processed video to `uint16`.
7. Builds the projection table.

### Blood-Vessel Projection

`CaliAli_get_blood_vessels` enhances vessels from the median image. It removes
vignetting with `remove_vignetting_video_adaptive_batches`, applies a vesselness
filter across the configured `BVsize` range, applies median filtering for 2-D
inputs, and converts the result to `uint8`.

### Background Removal

`CaliAli_remove_background` applies the preprocessing requested in
`CaliAli_options.preprocessing`:

- `detrend_vid` removes slow fluorescence changes using a moving median followed
  by a longer moving minimum filter.
- `noise_scaling` normalizes pixels by estimated noise.
- `MIN1PIPE_bg_removal` enhances neuronal structures for
  `preprocessing.structure = 'neuron'`.
- dendrite-specific background removal is used when
  `preprocessing.structure = 'dendrite'`.
- an optional median filter can be applied frame-by-frame.
- negative values are shifted and clipped when `force_non_negative` is enabled.

### Neuron And PNR Projections

The projection method depends on preprocessing settings:

- `fastPNR = true` calls `get_PNR_Cn_fast`.
- `structure = 'dendrite'` calls `get_PNR_Cn_dendrite`.
- otherwise, the default path calls `get_PNR_coor_greedy_PV`, producing the
  correlation image `Cn` and peak-to-noise ratio image `PNR`.

If more than 1 percent of pixels exceed the `uint16` ceiling after
preprocessing, the function prints a saturation warning before clipping values
above `65535`.

### Projection Table Stored In `_det.mat`

Each `*_det.mat` file stores an updated
`CaliAli_options.inter_session_alignment.P` table:

| Column | Name | Meaning |
| --- | --- | --- |
| 1 | `Mean` | Median or mean-like structural projection used for display and vignetting context. |
| 2 | `BloodVessels` | Vesselness-filtered blood-vessel image. |
| 3 | `Neurons` | Correlation image `Cn`. |
| 4 | `PNR` | Peak-to-noise ratio projection. |
| 5 | `BV+Neurons` | Fused RGB visualization of neuron and blood-vessel projections. |

The file also stores:

- detrended/background-corrected `Y`;
- frame count `F`;
- intensity `range`;
- normalized `Cn`;
- `Cn_scale`;
- `PNR`.

For internally batched sessions, projections are accumulated across chunks:
mean and blood-vessel projections are summed, `Cn` and `PNR` keep maxima, and
the fused image keeps a maximum across chunks.

## Stage 4: Detrended Output Checks

After `_det.mat` creation or reuse, `verify_detrended_outputs` checks that the
number of detrended output files matches the number of sessions and that each
`*_det.mat` file has the same frame count as the original input.

It also checks the last frame of each detrended `Y`. A zero last frame raises a
`CaliAli:frameCheck` error. Frame-count mismatches are reported with the
session label and pipeline stage.

The verified frame counts are stored as:

```matlab
CaliAli_options.inter_session_alignment.detrend_F
```

## Stage 5: Output Filename

The aligned output filename is derived from the last detrended output file:

```matlab
CaliAli_options.inter_session_alignment.out_aligned_sessions = ...
    [output_files{end}(1:end-7), 'Aligned.mat'];
```

For a file named `session_det.mat`, this produces `session_Aligned.mat`.

## Stage 6: Matching Video Sizes

`match_video_size` makes all detrended session files spatially compatible before
alignment.

It reads each `*_det.mat`, creates a mask matching its frame size, centers all
masks with `catpad_centered`, and computes a common valid region. If sessions
have different spatial sizes, `replace_in` crops each session's `Y`, projection
table, `Cn`, and `PNR` to the common mask and saves the modified data back to
disk.

If all masks already have the same number of pixels, it reports that the session
pixel counts match and leaves the files unchanged.

## Stage 7: Loading Stored Projections

`get_stored_projections` loads the projection table from each `*_det.mat` file
and concatenates the sessions into a single table. For each projection field it
concatenates along the next dimension, so each session becomes one plane in the
projection stack.

It then rescales the neuron projection and blood-vessel projection for display
and rebuilds the fused `BV+Neurons` visualization.

This initial projection table is called `P1` in `CaliAli_align_sessions`.

## Stage 8: Translation Alignment

`sessions_translate` estimates rigid translation between sessions.

Reference choice:

- if `inter_session_alignment.projections` contains `'BV'`, it aligns using the
  blood-vessel projection;
- otherwise it aligns using the neuron projection.

The function uses NoRMCorre:

```matlab
normcorre_batch(...)
```

It crops a 20-pixel border before estimating shifts, then recenters the shift
set by subtracting the mean shift. This makes all sessions move into a common
coordinate system rather than using one session as an absolute fixed target.

The estimated shifts are applied to every projection except the fused display
image, which is recomputed afterward. `remove_borders` crops away invalid NaN
borders introduced by shifting.

Stored outputs:

```matlab
CaliAli_options.inter_session_alignment.T       % one [x y] shift per session
CaliAli_options.inter_session_alignment.T_Mask  % valid region after translation
```

If translation alignment is disabled, or if there is only one unique
`same_ses_id`, the function stores zero shifts and a full valid mask.

## Stage 9: Non-Rigid Alignment

`sessions_non_rigid` estimates a displacement field for each session.

If non-rigid alignment is disabled, or if there is only one unique
`same_ses_id`, it stores zero displacement fields and returns.

### Handling Split Sessions

If `same_ses_id` is set, `average_P_same_sessions` first averages projections
belonging to the same biological session. This prevents chunks from the same
session from being treated as independent sessions during non-rigid estimation.

After shifts are estimated, `expand_P_from_same_session_batches` copies each
session-level shift back to all matching input entries.

### Projection Preparation

The nested `pre_allocate_projections` helper prepares the images used for
registration:

- `Mb`: mean image converted to `uint8`;
- `Vf`: blood-vessel image converted to `uint8`;
- `Cn`: neuron image enhanced as `mat2gray(PNR) .* mat2gray(Cn).^2` and then
  contrast-equalized with `adapthisteq`;
- `X`: fused max projection of blood vessels and median-filtered neurons.

If alignment is neuron-only, or if `projections` does not include blood
vessels, the blood-vessel channel is replaced with the neuron channel. If
`projections` does not include neurons, the neuron channel is replaced with the
blood-vessel channel.

### Pairwise Log-Demons Registration

For every pair of sessions, `get_matrices` calls `get_transformations` in both
directions. `get_transformations` uses `MR_Log_demon`, which performs
multi-resolution Log-Demons registration through `register_in`.

Each pair produces:

- a forward displacement field;
- a backward displacement field;
- a local similarity map from `get_local_corr_Vf`;
- a global correlation score.

`arrange_matrix` reorganizes the pairwise fields into an `n x n` session matrix.
It then builds:

- `globW`: one global reliability weight per session;
- `LocW`: local pixel-wise reliability weights smoothed with a large Gaussian.

The final displacement for each session is the weighted sum of all pairwise
fields. NaNs are set to zero, and the mean displacement across sessions is
subtracted so the final fields are centered around a common coordinate system.

### Applying The Non-Rigid Fields To Projections

The displacement fields are applied to each projection plane using `imwarp`.
Invalid borders are cropped with `remove_borders`.

Stored outputs:

```matlab
CaliAli_options.inter_session_alignment.shifts
CaliAli_options.inter_session_alignment.NR_Mask
```

If this is the optional final neuron-only pass, the fields are stored instead as:

```matlab
CaliAli_options.inter_session_alignment.shifts_n
CaliAli_options.inter_session_alignment.NR_Mask_n
```

## Stage 10: Optional Final Neuron Alignment

If `inter_session_alignment.final_neurons` is true, the main function calls:

```matlab
[P4, CaliAli_options] = sessions_non_rigid(P3, CaliAli_options, true);
```

The third argument forces `sessions_non_rigid` to align using neuron-derived
features only. This adds an extra refinement after the regular CaliAli
alignment.

The final projection table saved in the options has either three or four
columns:

| Column | Meaning |
| --- | --- |
| `Original` | Projections before inter-session alignment. |
| `Translations` | Projections after rigid translation. |
| `CaliAli` | Projections after translation plus non-rigid alignment. |
| `CaliAli+neurons` | Optional final neuron-only refinement. |

## Stage 11: Fused Projection Display

`BV_gray2RGB` rebuilds the fused RGB display image for each alignment stage.
It enhances the neuron projection using the `PNR .* Cn^2` style weighting,
equalizes contrast, and fuses the neuron and blood-vessel channels with:

```matlab
imfuse(..., 'ColorChannels', [1 2 0])
```

If `same_ses_id` is set, it also averages display projections for batches that
belong to the same biological session.

## Stage 12: Blood-Vessel Quality Check And Fallback

If the selected projection mode contains `'BV'`, `evaluate_BV` checks whether
the blood-vessel-based non-rigid alignment is stable:

```matlab
CaliAli_options.inter_session_alignment.BV_score = get_BV_NR_score(P, 2);
```

`get_BV_NR_score` compares the actual blood-vessel similarity against 100
randomized non-rigid perturbations generated with `Add_NRmotion_reg`. The score
is essentially a standardized distance between real alignment quality and
randomly perturbed alignment quality.

If:

```matlab
BV_score < 2.7 && Force_BV == 0
```

the function warns that blood-vessel similarity is too low, switches:

```matlab
CaliAli_options.inter_session_alignment.projections = 'Neuron';
```

and recomputes translation, non-rigid alignment, and optional final neuron
alignment from the original projections.

This is the automatic fallback path for sessions where blood vessels are not
reliable alignment landmarks.

At the end, `get_neuron_projections_correlations(P, 3)` reports whether neuron
projection correlations look acceptable. Low-correlation session pairs are
reported as warnings.

## Stage 13: Alignment Metrics

After final projections are selected, the main function stores:

```matlab
CaliAli_options.inter_session_alignment.P = P;
CaliAli_options.inter_session_alignment.alignment_metrics = get_alignment_metrics(P);
```

`get_alignment_metrics` evaluates each alignment stage using the fused
projection stack. It calls:

- `get_matched_projection` to create a display image with local histogram
  matching;
- `motion_metrics` to calculate correlation scores and crispness.

The output is a table with:

- transformation name;
- tested projection type;
- display projection;
- frame/session correlation scores;
- mean correlation score;
- crispness.

## Stage 14: Applying Transforms To Full Videos

`apply_transformations` applies the final transforms to every frame of the
detrended videos.

It first checks whether the aligned output file already exists:

- if the file exists and contains `alignment_completed = true`, it reuses the
  aligned file and returns;
- if the file exists but the completion flag is missing or false, it deletes the
  incomplete file and recomputes.

Then it writes:

```matlab
alignment_completed = false
```

to the aligned file before starting. This protects against interrupted runs
being mistaken for complete outputs.

For each input batch, the function changes the batch source path to the
corresponding `*_det.mat` file:

```matlab
TheFiles{i}{1} = TheFiles{i}{5};
```

This means full-frame alignment is applied to the detrended/background-corrected
video, not to the original raw input.

For each batch it:

1. loads `Y` from the `*_det.mat` file;
2. applies translation with `imtranslate` and crops with `T_Mask`;
3. applies non-rigid shifts with `imwarp` and crops with `NR_Mask`;
4. optionally applies final neuron-only non-rigid shifts and `NR_Mask_n`;
5. appends the aligned chunk to the global `*_Aligned.mat` stack using
   `CaliAli_save_chunk`.

Frame accounting is checked while writing:

- per-session aligned frame totals are compared to `input_F`;
- cumulative aligned frames are compared to expected cumulative totals;
- after all chunks are written, final per-session frame totals are checked;
- the final aligned `Y` frame count is compared to `sum(input_F)`;
- the last frame of the aligned output is checked for all zeros.

If final verification succeeds, the function writes:

```matlab
alignment_completed = true
```

## Stage 15: Saving Final Variables

Finally, `save_relevant_variables` appends the final options structure to the
aligned file.

It derives final summary projections from the last column of `P`:

```matlab
CaliAli_options.inter_session_alignment.Cn
CaliAli_options.inter_session_alignment.Cn_scale
CaliAli_options.inter_session_alignment.PNR
```

Then it saves:

```matlab
CaliAli_save(out_aligned_sessions, CaliAli_options);
```

The aligned file therefore contains the concatenated aligned video `Y`, the
completion flag, and `CaliAli_options` with the transforms, masks, projections,
metrics, frame counts, and output paths.

## Output Files

### `*_det.mat`

One per input session, or one per original session when internal batching is
used. It stores:

- `Y`: detrended and background-corrected video;
- `CaliAli_options.inter_session_alignment.P`: projection table;
- `F`: frame count;
- `range`: post-preprocessing intensity range;
- `Cn`, `Cn_scale`, and `PNR`;
- updated preprocessing and alignment options.

These files are reusable. If they already exist and do not look corrupted, the
pipeline skips detrending and projection calculation.

### `*_Aligned.mat`

One final aligned output. It stores:

- `Y`: transformed and concatenated aligned video;
- `alignment_completed`: completion flag used to avoid reusing incomplete
  outputs;
- `CaliAli_options`: final options and alignment results.

Important saved alignment fields include:

| Field | Meaning |
| --- | --- |
| `P` | Projection table for each alignment stage. |
| `T` | Translation vector per session. |
| `T_Mask` | Valid crop after translation. |
| `shifts` | Non-rigid displacement field per session. |
| `NR_Mask` | Valid crop after non-rigid alignment. |
| `shifts_n` | Optional final neuron-only displacement field. |
| `NR_Mask_n` | Optional final neuron-only crop mask. |
| `BV_score` | Blood-vessel stability score. |
| `alignment_metrics` | Correlation and crispness metrics. |
| `input_F` | Original frame counts. |
| `detrend_F` | Detrended output frame counts. |
| `Cn`, `Cn_scale`, `PNR` | Final summary projections for later extraction/initialization. |

## Data Integrity And Error Checks

The alignment pipeline has several safeguards:

| Stage | Check |
| --- | --- |
| Before detrending | Records original frame counts with `get_data_dimension`. |
| Before detrending | Rejects files whose last `Y` frame is all zeros. |
| Before `_det.mat` reuse | Deletes unreadable outputs or outputs with an all-zero last frame. |
| After detrending | Compares `_det.mat` frame counts to original input frame counts. |
| After detrending | Rejects detrended files whose last `Y` frame is all zeros. |
| During aligned writing | Checks per-session and cumulative frame counts. |
| After aligned writing | Compares final aligned frame count to `sum(input_F)`. |
| After aligned writing | Checks the final aligned last frame for all zeros. |
| Aligned file reuse | Uses `alignment_completed` to avoid treating interrupted outputs as valid. |

Most frame-count mismatches are reported as warnings or red console messages.
All-zero last frames in input or detrended files raise a `CaliAli:frameCheck`
error because they usually indicate a truncated or incomplete dataset.

## Practical Notes

- `*_det.mat` files are the cache boundary. Delete them if you want to force
  recalculation of detrending, background removal, and projections.
- `*_Aligned.mat` is also reused when `alignment_completed = true`. Delete it if
  you want to force final transform application again.
- `same_ses_id` should be used when multiple files are parts of the same
  biological session. The code estimates one non-rigid transform per unique
  session id and expands it back to the corresponding files.
- Blood-vessel alignment is preferred by default when `projections` includes
  `'BV'`, but the pipeline can automatically switch to neuron alignment when
  blood-vessel similarity is unstable.
- Always visually inspect `CaliAli_options.inter_session_alignment.P` and the
  `alignment_metrics` table before running CNMF-E extraction.

## Called-Function Map

| Function | Role |
| --- | --- |
| `CaliAli_parameters` | Builds and validates option structures. |
| `record_input_frame_counts` | Stores original frame counts and checks last frames. |
| `detrend_batch_and_calculate_projections` | Creates or reuses `*_det.mat` files. |
| `create_batch_list` | Splits sessions into processing batches. |
| `pre_allocate_outputs` | Decides whether each batch needs processing and pre-allocates output files. |
| `remove_corrupted_output` | Deletes incomplete/corrupted cached outputs. |
| `get_projections_and_detrend` | Performs preprocessing and creates projection tables. |
| `CaliAli_get_blood_vessels` | Creates blood-vessel projections. |
| `CaliAli_remove_background` | Detrends, noise-scales, and background-corrects videos. |
| `verify_detrended_outputs` | Confirms `_det.mat` frame counts and last frames. |
| `match_video_size` | Crops sessions to a shared spatial size. |
| `get_stored_projections` | Loads and concatenates cached projections. |
| `sessions_translate` | Estimates rigid translation with NoRMCorre. |
| `sessions_non_rigid` | Estimates non-rigid displacement fields with Log-Demons registration. |
| `average_P_same_sessions` | Combines projections from split files with the same session id. |
| `expand_P_from_same_session_batches` | Expands session-level shifts back to split files. |
| `BV_gray2RGB` | Builds fused neuron/BV display projections. |
| `get_BV_NR_score` | Scores blood-vessel alignment reliability. |
| `get_neuron_projections_correlations` | Reports low-correlation neuron projection pairs. |
| `get_alignment_metrics` | Builds the metrics table for alignment quality. |
| `apply_transformations` | Applies stored transforms to full detrended videos. |
| `CaliAli_save_chunk` | Writes aligned chunks into the final aligned stack. |
| `save_relevant_variables` | Appends final projections and options to `*_Aligned.mat`. |
