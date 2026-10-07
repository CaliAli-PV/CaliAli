### match_video_size {#match_video_size}

```matlab
function CaliAli_options = match_video_size(CaliAli_options)
```

#### Description
Ensure consistent video dimensions across sessions.

This function aligns video dimensions across multiple sessions by cropping borders to match a common mask. It ensures that sessions dimensions match before performing inter-session alignment.

##### Function Inputs:
| Parameter Name | Type    | Description                                       |
|----------------|---------|---------------------------------------------------|
| CaliAli_options| Structure| Structure containing configuration options for alignment.|

The details of this structure can be found in CaliAli_demo_parameters().

##### Function Outputs:
| Parameter Name | Type    | Description                                       |
|----------------|---------|---------------------------------------------------|
| CaliAli_options| Structure| Updated structure. `inter_session_alignment.F` holds the number of frames of each session and `inter_session_alignment.Mask` the region of each session that is kept. |

##### Example usage:
```matlab
CaliAli_options = match_video_size(CaliAli_options);
```

##### Notes:
- Sessions are compared by their frame size (height and width). If all sessions already match, nothing is changed.
- Otherwise, each session is cropped to the centered region shared by all sessions, and the result is written back to the same file. The video is processed in batches (`batch_sz`), and the original file is replaced only once the cropped copy is complete.
- The projections stored with each session (`P`, `Cn` and `PNR`) are cropped in the same way.
- An error is raised if the region shared by all sessions is not a rectangle.
- [CaliAli_align_sessions()](CaliAli_align_sessions.md#CaliAli_align_sessions) runs this step automatically.
