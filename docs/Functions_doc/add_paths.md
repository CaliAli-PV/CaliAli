### add_paths {#add_paths}

#### Syntax
```matlab
function paths_added = add_paths()
```

#### Description
`add_paths` adds the CaliAli folder and all its subfolders (except `.git`) to the MATLAB path. It is an alternative to adding the folders manually during [installation](../Installation.md#installation).

##### Function Outputs
| Name | Type | Description |
|------|------|-------------|
| `paths_added` | cell | (Optional) Folders that were added to the path. If not requested, the number of folders added is printed instead. |

##### Notes
- `add_paths.m` is in the main CaliAli folder, so run it from there (or with its full path).
- The change lasts for the current MATLAB session. Run it again after restarting MATLAB, or keep it with `savepath`.

##### Example Usage
```matlab
cd('path/to/CaliAli');   % folder where CaliAli was downloaded
add_paths();
```
