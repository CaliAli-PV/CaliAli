### CaliAli_save_chunk {#CaliAli_save_chunk}

```matlab
function CaliAli_save_chunk(filename, Y,Id)
```

#### Description
CaliAli_save_chunk: Save or append video data to a .mat file in chunks.

##### Function Inputs:
| Parameter Name | Type   | Description                 |
|---------------|--------|-----------------------------|
| filename      | String | String specifying the file path to save or append data. |
| Y             | 3D Array| 3D array containing the video data to be stored. |
| Id            | 3D Array| Id of the session being saved|

##### Function Outputs:
| Parameter Name | Type    | Description         |
|---------------|---------|---------------------|


##### Example usage:
```matlab
CaliAli_save_chunk('output.mat', Y, 2);
```

Notes:

- If the file exists, new data is appended along the third dimension.
- If the file does not exist, a new file is created with '-v7.3' format.
- No compression is used to optimize read/write speed.
