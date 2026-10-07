### update_folder_path {#update_folder_path}

#### Syntax
```matlab
function neuron=update_folder_path(neuron)
```

#### Description
`update_folder_path` points a `neuron` object to the new location of its files after you move or copy the extraction results to another folder or computer. A folder picker opens: select the `..._source_extraction` folder created during extraction (see the [checkpoint layout](../extraction.md#chk)).

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `neuron` | CNMF-E neuron object | Output of [CaliAli_cnmfe()](CaliAli_cnmfe.md#CaliAli_cnmfe), loaded from a checkpoint. |

##### Function Outputs
| Name | Type | Description |
|------|------|-------------|
| `neuron` | CNMF-E neuron object | The same object, now reading the video data from the selected folder and saving new checkpoints in a `LOGS_<DATE>` folder inside it. |

##### Notes
- Run it before any step that reads the video again, such as [manually_update_residuals()](manually_update_residuals.md#manually_update_residuals) or [play_movie()](play_movie.md#play_movie).
- The change is not stored on disk until you save the workspace.

##### Example Usage
```matlab
neuron = update_folder_path(neuron);
save_workspace(neuron);
```
