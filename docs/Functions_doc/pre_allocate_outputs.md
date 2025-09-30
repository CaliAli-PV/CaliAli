
### pre_allocate_outputs {#pre_allocate_outputs}

#### Syntax
```matlab
function process_flags = pre_allocate_outputs(input_files, tag)
```

#### Description
`pre_allocate_outputs` creates placeholder MAT-files for chunked processing and reports which batches still need work. For traditional inputs it simply checks whether the derived output file exists; for chunked runs it creates the destination datasets at the proper size using `matfile` so downstream steps can stream results directly to disk.

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `input_files`  | cell | Elements are either raw filenames or chunk descriptors produced by `create_batch_list`. |
| `tag`          | char | Suffix appended to output filenames (e.g. `'_mc'`, `'_det'`). |

##### Function Outputs
| Name | Type | Description |
|------|------|-------------|
| `process_flags` | logical array | Logical mask indicating which entries require processing (`true`) versus already-complete batches (`false`). |

##### Example Usage
```matlab
input_files = create_batch_list(opt.input_files, opt.batch_sz, '_det');
process_flags = pre_allocate_outputs(input_files, '_det');

for k = find(process_flags)
    Y = CaliAli_load(input_files{k}, 'Y');
    % ... process chunk ...
    CaliAli_save(input_files{k}(:), Y, CaliAli_options);
end
```
