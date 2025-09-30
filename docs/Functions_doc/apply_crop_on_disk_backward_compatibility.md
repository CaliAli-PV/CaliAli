
### apply_crop_on_disk_backward_compatibility {#apply_crop_on_disk_backward_compatibility}

#### Syntax
```matlab
function apply_crop_on_disk_backward_compatibility(file_list)
```

#### Description
`apply_crop_on_disk_backward_compatibility` ensures legacy motion-corrected files gain the cropping mask required by the new chunking pipeline. For each input MAT-file it computes the mask (if missing), updates `CaliAli_options.motion_correction.Mask`, and then calls `apply_crop_on_disk` so the stored video is cropped consistently.

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `file_list`    | cell | Cell array of MAT-file paths to inspect and update. |

##### Behaviour
- Skips files that already contain a non-empty mask.
- Reuses `create_batch_list` to iterate through chunk descriptors when generating the mask.
- Invoked automatically before detrending/projection calculations to keep historical datasets compatible with the batched workflow.

##### Example Usage
```matlab
apply_crop_on_disk_backward_compatibility(opt.input_files);
```
