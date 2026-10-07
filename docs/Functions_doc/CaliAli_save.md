### CaliAli_save {#CaliAli_save}

```matlab
function CaliAli_save(target, varargin)
```

#### Description
CaliAli_save: Save or append variables to a MAT-file.

##### Function Inputs:
| Parameter Name | Type   | Description                              |
|---------------|--------|------------------------------------------|
| target        | String or cell array | File path to save or append to, or a chunk descriptor `{filename, session_id, start_frame, end_frame, output_filename}` from [create_batch_list](create_batch_list.md#create_batch_list). With a chunk descriptor, data are written to `output_filename`, and `Y` is written into frames `start_frame` to `end_frame`. |
| varargin      | List   | Variables to save, either as name/value pairs (`'Y', Y, ...`) or as variables, which are saved under their own names. Use name/value pairs when passing expressions, which have no name. |

##### Function Outputs:
| Parameter Name | Type | Description                      |
|---------------|------|----------------------------------|
| None          | None | Data is saved to the specified file. |

##### Example usage:
```matlab
CaliAli_save('output.mat', var1, var2);                      % saved as var1 and var2
CaliAli_save('output.mat', 'Y', Y, 'CaliAli_options', opt);  % name/value pairs
CaliAli_save(batches{k}, 'Y', Y);                            % write one chunk
```
