
### create_batch_list {#create_batch_list}

#### Syntax
```matlab
function [modified_input_files, batch_sz, F] = create_batch_list(input_files, batch_sz, tag)
```

#### Description
`create_batch_list` splits each session file into chunks of at most `batch_sz` frames, so long recordings can be processed without loading them whole. Chunks of the same session have nearly equal length. Frame counts are read from the file without loading the data, and files keep the order in which they were given.

##### Function Inputs
| Parameter Name | Type    | Description |
|----------------|---------|-------------|
| `input_files`  | cell or char | Session file path, or cell array of paths. |
| `batch_sz`     | numeric or char | Maximum number of frames per chunk, or one of `'auto'`, `'all_frames'`, `'per_session'` (see [Low-Memory Processing](../Low_memory.md)). `'all_frames'`, `'per_session'` and `0` keep each file as a single chunk. |
| `tag`          | char    | Suffix added to the output filenames (for example `'_mc'` or `'_det'`), unless the name already contains it. |

##### Function Outputs
| Name | Type | Description |
|------|------|-------------|
| `modified_input_files` | cell | One entry per chunk, each a cell array `{filename, session_id, start_frame, end_frame, output_filename}`. |
| `batch_sz` | numeric | Number of frames per chunk that was used; `0` means each file is one chunk. |
| `F` | numeric | Total number of frames in each input file. |

##### Example Usage
```matlab
% Split motion-correction inputs into chunks of at most 3000 frames.
[batches, batch_sz, F] = create_batch_list(opt.input_files, 3000, '_mc');

% Process each chunk with CaliAli_load / CaliAli_save.
for k = 1:numel(batches)
    Y = CaliAli_load(batches{k}, 'Y');
    % ... process chunk ...
    CaliAli_save(batches{k}, 'Y', Y);
end
```
