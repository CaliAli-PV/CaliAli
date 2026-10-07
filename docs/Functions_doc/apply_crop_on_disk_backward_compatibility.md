
### apply_crop_on_disk_backward_compatibility {#apply_crop_on_disk_backward_compatibility}

#### Syntax
```matlab
function apply_crop_on_disk_backward_compatibility(Flist, options_main)
```

#### Description
`apply_crop_on_disk_backward_compatibility` checks files that were not motion-corrected by CaliAli (for example, corrected with an external tool) for black borders at the frame edge. It only warns: the files are not modified. Inter-session alignment calls it automatically before detrending.

If you see the warning `Uncropped border in ...`, crop the borders of that session before aligning, or run CaliAli's own motion correction on it. See [Can I use CaImAn or Suite2p for motion correction?](../FAQ.md#external-mc)

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `Flist`        | cell or char | MAT-file path, or cell array of paths (or chunk descriptors from [create_batch_list](create_batch_list.md#create_batch_list)), to check. |
| `options_main` | struct | (Optional) CaliAli options. Accepted but not used. |

##### Behaviour
- Files whose `CaliAli_options.motion_correction.Mask` is set (that is, motion-corrected by CaliAli) are skipped.
- Only borders of zeros that touch the frame edge are reported; dark pixels inside the field of view are ignored.

##### Example Usage
```matlab
apply_crop_on_disk_backward_compatibility(CaliAli_options.inter_session_alignment.input_files);
```
