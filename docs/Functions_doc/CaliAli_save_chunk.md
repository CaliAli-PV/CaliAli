### CaliAli_save_chunk {#CaliAli_save_chunk}

```matlab
function CaliAli_save_chunk(out, fullFileName, F, Y, ix)
```

!!! note "Internal function"
    Inter-session alignment calls this function to write each aligned chunk into the `_Aligned.mat` file. You do not need to call it yourself.

#### Description
CaliAli_save_chunk: Write one chunk of aligned video into the concatenated output file, at the frames that belong to its session.

##### Function Inputs:
| Parameter Name | Type   | Description                 |
|---------------|--------|-----------------------------|
| out           | String | Path of the output `.mat` file. Created on the first call, appended to afterwards. |
| fullFileName  | Cell array | Chunk descriptor `{filename, session_id, start_frame, end_frame, output_filename}` from [create_batch_list](create_batch_list.md#create_batch_list). |
| F             | Vector | Number of frames in each session. |
| Y             | 3D array | Video data for this chunk. |
| ix            | Integer | Index of the session the chunk belongs to. |

##### Function Outputs:
None. The data are written to `out`.
