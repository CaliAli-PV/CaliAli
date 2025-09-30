### CaliAli_crop {#CaliAli_crop}

#### Syntax
```matlab
function CaliAli_crop(backup_options)
```

#### Description
`CaliAli_crop` launches an interactive workflow to define a spatial crop that is applied across multiple motion-correction inputs. The function loads each selected MAT file, collects representative frames, shows an averaged projection in `crop_app`, and then writes the cropped data back to disk in-place. Use this tool before detrending or alignment so downstream steps operate on the trimmed field of view.

##### Function Inputs
| Parameter Name   | Type   | Description |
|------------------|--------|-------------|
| `backup_options` | struct | (Optional) CaliAli options structure saved into files that do not yet contain `CaliAli_options`. Pass an empty array to skip this behaviour. |

##### Notes
- Works on MAT files that contain a `Y` variable (d1 × d2 × d3) and, ideally, an embedded `CaliAli_options` structure.
- The GUI displays the median frame of each session and lets you draw a shared crop that is applied to all files.
- Cropping is performed by calling the on-disk helper used during motion correction, so large stacks are processed in batches determined by `motion_correction.batch_sz`.
- Because cropping changes frame dimensions, run this function **before** computing projections, detrending, or alignment products.

##### Example Usage
```matlab
% Use existing options as a fallback for files missing CaliAli_options
CaliAli_crop(CaliAli_options);

% Prompt for files and crop without providing defaults
CaliAli_crop([]);
```
