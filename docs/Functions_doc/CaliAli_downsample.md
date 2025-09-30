### CaliAli_downsample {#CaliAli_downsample}

#### Syntax
```matlab
function CaliAli_options=CaliAli_downsample(varargin)
```

#### Description
This function performs temporal and spatial downsampling on selected video files. 
Supported formats include .avi, .m4v, .mp4, .tif, .tiff, .isxd, and .h5.

##### Function Inputs:
| Parameter Name | Type   | Description                                                                 |
|---------------|--------|-----------------------------------------------------------------------------|
| varargin      | array  | Variable input arguments, which are parsed into [CaliAli_options](CaliAli_parameters.md) .          |

##### Function Outputs:
| Parameter Name    | Type           | Description                                                              |
|-------------------|----------------|--------------------------------------------------------------------------|
| [CaliAli_options](CaliAli_parameters.md)    | structure      | Updated structure containing the downsampling parameters.            |

##### Example usage:
```matlab
CaliAli_options = CaliAli_downsample();   % Interactive file selection
CaliAli_options = CaliAli_downsample(CaliAli_options);   % Using predefined options
```
