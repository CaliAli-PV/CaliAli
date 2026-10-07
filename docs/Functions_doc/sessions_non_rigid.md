### sessions_non_rigid {#sessions_non_rigid}

```matlab
function [P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options, neurons_only)
```

#### Description
`sessions_non_rigid`: Perform non-rigid alignment for session data.

##### Function Inputs:
| Parameter Name | Type    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| P               | Table     | Session projections, as returned by [sessions_translate()](sessions_translate.md#sessions_translate) (columns `Mean`, `BloodVessels`, `Neurons`, `PNR`, `BV+Neurons`; one image per session file in each). |
| CaliAli_options | Structure | Structure containing configuration options for alignment.                 |
| neurons_only    | Boolean   | (Optional) Boolean flag indicating whether to align only neuron data. Default is false. |

##### Function Outputs:
| Parameter Name | Type    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| P               | Table     | Projections after the non-rigid alignment, cropped to the region covered by all sessions. |
| CaliAli_options | Structure | Updated structure. Writes `inter_session_alignment.shifts` (displacement field of each session) and `inter_session_alignment.NR_Mask` (region kept), or `shifts_n` and `NR_Mask_n` when `neurons_only` is `true`. |

##### Example usage:
```matlab
[P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options);
[P, CaliAli_options] = sessions_non_rigid(P, CaliAli_options, true);  % Align utilizing only neurons projections
```

##### Notes:
- If `do_alignment_non_rigid` is `false`, or all files belong to the same session (`same_ses_id`), no displacement is applied (the shifts are all zeros).
- Files that belong to the same session (`same_ses_id`) are aligned together and share one displacement field.
