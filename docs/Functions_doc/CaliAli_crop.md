### CaliAli_crop {#CaliAli_crop}

#### Syntax
```matlab
function CaliAli_crop(backup_options)
```

#### Description
`CaliAli_crop` is an optional, interactive crop applied to several motion-corrected sessions at once. [Motion correction](CaliAli_motion_correction.md#CaliAli_motion_correction) already crops each video to the region that holds real data, so use this tool only to trim the field of view further (for example, to remove an unused part of the frame). It prompts for the MAT files, shows a frame from each session in `crop_app`, and overwrites each file with the cropped data.

##### Function Inputs
| Parameter Name   | Type   | Description |
|------------------|--------|-------------|
| `backup_options` | struct | (Optional) CaliAli options structure saved into any selected file that does not contain `CaliAli_options`. If it is omitted or empty and such a file is found, the function stops before cropping anything. |

##### Notes
- Works on MAT files that contain a `Y` variable (d1 × d2 × d3) and a `CaliAli_options` structure, such as `_mc.mat` files.
- The window shows the middle frame of each session (use the slider to switch sessions); the rectangle you draw is applied to all files.
- Large videos are cropped in chunks of `motion_correction.batch_sz` frames.
- Because cropping changes frame dimensions, run this function **before** computing projections, detrending, or alignment products.

##### Example Usage
```matlab
% Use existing options as a fallback for files missing CaliAli_options
CaliAli_crop(CaliAli_options);

% Files already contain CaliAli_options (e.g. _mc.mat files)
CaliAli_crop();
```
