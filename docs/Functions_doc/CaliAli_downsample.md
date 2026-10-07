### CaliAli_downsample {#CaliAli_downsample}

#### Syntax
```matlab
function CaliAli_options = CaliAli_downsample(CaliAli_options)
```

#### Description
This function performs temporal and spatial downsampling on selected video files and converts them to the `.mat` format used by CaliAli.
Supported formats include .avi, .m4v, .mp4, .tif, .tiff, .isxd, and .h5.

##### Function Inputs:
| Parameter Name | Type   | Description                                                                 |
|---------------|--------|-----------------------------------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md) | structure | (Optional) Options structure. Settings are read from `CaliAli_options.downsampling` (e.g. `spatial_ds`, `temporal_ds`, `batch_sz`, `output_class`). If `input_files` is empty, or no input is given, a file picker opens. |

##### Function Outputs:
| Parameter Name    | Type           | Description                                                              |
|-------------------|----------------|--------------------------------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md)    | structure      | Updated structure; `CaliAli_options.downsampling.output_files` lists the files created.            |

##### Example usage:
```matlab
CaliAli_options = CaliAli_downsample();   % Interactive file selection
CaliAli_options = CaliAli_downsample(CaliAli_options);   % Using predefined options
```

##### Notes
- Each video is saved next to the original as `<name>_ds.mat`. A complete `_ds.mat` that already exists is skipped.
- Data are stored in the class set by `output_class` (`'uint16'` by default). See [Bit depth](../Downsampling.md#output-class).
- Dead pixels, dropped frames and constant borders are repaired before downsampling. See [Camera defects](../Downsampling.md#defects).
- Selecting a folder instead of a file concatenates all its files of type `file_extension` into one `<folder>_con.mat`. See [Processing Split Data](../Processing_split_data.md).
- Settings are passed only through the options structure; name/value pairs are not accepted.
- Older scripts that call `CaliAli_downsample_batch` still work: it forwards to this function.
