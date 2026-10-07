### CaliAli_motion_correction {#CaliAli_motion_correction}

```matlab
function CaliAli_options = CaliAli_motion_correction(varargin)
```

#### Description
CaliAli_motion_correction: Perform rigid and, optionally, non-rigid motion correction on video files.

This function applies rigid motion correction to a set of input video files, and non-rigid correction when `do_non_rigid = true` (see [Non-rigid motion correction](../Motion_correction.md#non-rigid)). It interpolates dropped frames, crops each video to the region that holds real data in every frame, and saves the corrected video as a .mat file.

##### Function Inputs:
| Parameter Name | Type | Description |
|---------------|------|-------------|
| varargin | Variable-length input argument list | Variable input arguments, which are parsed into  [CaliAli_options](CaliAli_parameters.md). If `motion_correction.input_files` is empty, a file picker opens for `_ds.mat` and `_con.mat` files. |

##### Function Outputs:
| Parameter Name | Type | Description |
|---------------|------|-------------|
|  [CaliAli_options](CaliAli_parameters.md) | Structure | Updated structure; `CaliAli_options.motion_correction.output_files` lists the motion-corrected files. |

##### Example usage:
```matlab
CaliAli_options = CaliAli_motion_correction();   % Interactive file selection
CaliAli_options = CaliAli_motion_correction(CaliAli_options);   % Using predefined options
```

##### Notes
- Each input is saved next to the original with the suffix `_mc` (e.g. `session1_ds.mat` becomes `session1_ds_mc.mat`). Outputs that already exist are skipped.
- The borders left empty by the correction are cropped automatically. [`CaliAli_crop`](CaliAli_crop.md#CaliAli_crop) is only needed if you want to trim the field of view further.
- Files that did not go through `CaliAli_downsample` are checked for camera defects here. See [Camera defects](../Downsampling.md#defects).
- The output keeps the data class of its input, which `output_class` sets during downsampling. See [Bit depth](../Downsampling.md#output-class).
