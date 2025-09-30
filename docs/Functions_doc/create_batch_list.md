
### create_batch_list {#create_batch_list}

#### Syntax
```matlab
function [modified_input_files, F] = create_batch_list(input_files, batch_sz, tag)
```

#### Description
`create_batch_list` prepares an input file list for chunk-aware processing. It inspects each session file, computes the number of frames, and emits either the original filename (when no batching is needed) or a cell array describing each chunk. The helper also reports per-session frame counts so downstream code can size outputs correctly.

##### Function Inputs
| Parameter Name | Type    | Description |
|----------------|---------|-------------|
| `input_files`  | cell    | Cell array of session file paths to process. |
| `batch_sz`     | numeric | Maximum number of frames per chunk. Values `<= 0` keep each session as a single element. |
| `tag`          | char    | Suffix appended to generated output filenames (for example `'_mc'` or `'_det'`). |

##### Function Outputs
| Name | Type | Description |
|------|------|-------------|
| `modified_input_files` | cell | List with one entry per chunk. Elements are either a string (when unchanged) or a cell array `{filename, session_id, start_frame, end_frame, output_filename}` describing the chunk. |
| `F` | numeric | Vector with the total number of frames for each original session. |

##### Example Usage
```matlab
% Split motion-correction inputs into 3000-frame batches.
[batches, frames] = create_batch_list(opt.input_files, 3000, '_mc');

% Process each returned element with CaliAli_load / CaliAli_save.
for k = 1:numel(batches)
    Y = CaliAli_load(batches{k}, 'Y');
    % ... process chunk ...
    CaliAli_save(batches{k}(:), Y, CaliAli_options);
end
```
