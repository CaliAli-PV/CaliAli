### sessions_translate {#sessions_translate}

```matlab
function [P, CaliAli_options] = sessions_translate(P, CaliAli_options)
```

#### Description
`sessions_translate`: Align session data by applying translation corrections.

##### Function Inputs:
| Parameter Name | Type   | Description                                    |
|----------------|--------|------------------------------------------------|
| P              | Table  | Session projections, as returned by [get_stored_projections()](get_stored_projections.md#get_stored_projections) (columns `Mean`, `BloodVessels`, `Neurons`, `PNR`, `BV+Neurons`; one image per session file in each). |
| CaliAli_options| Structure| Structure containing configuration options for alignment.|

##### Function Outputs:
| Parameter Name | Type   | Description                                    |
|----------------|--------|------------------------------------------------|
| P              | Table  | Projections after translation, cropped to the region covered by all sessions.|
| CaliAli_options| Structure| Updated structure. Writes `inter_session_alignment.T` (shift of each session) and `inter_session_alignment.T_Mask` (region kept after the shifts).|

##### Example usage:
```matlab
[P, CaliAli_options] = sessions_translate(P, CaliAli_options);
```

##### Notes:
- If `do_alignment_translation` is `false`, or all files belong to the same session (`same_ses_id`), no shift is applied (`T` is all zeros).
