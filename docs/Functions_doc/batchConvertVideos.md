### batchConvertVideos {#batchConvertVideos}

#### Syntax
```matlab
function batchConvertVideos(fileList, outputFolder)
```

#### Description
`batchConvertVideos` converts a list of videos into **lossless grayscale MP4 files** using FFmpeg: the one installed on the computer, or one CaliAli downloads the first time (see [Videos MATLAB cannot read](../Installation.md#ffmpeg)). If no list is given, a file picker opens. The converted videos are saved in `outputFolder` or, if none is given, in the folder of the first input file.

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `fileList` | cell array | (Optional) Paths of the videos to convert. If omitted, a file picker opens for `.avi`, `.mp4`, `.m4v`, `.tif`, `.tiff` or `.isxd` files. |
| `outputFolder` | char | (Optional) Folder for the converted MP4 files. It is created if it does not exist. If omitted, every converted file is saved in the folder of the first input file. |

##### Function Outputs
None. One `.mp4` file is written per input video, and a message is printed for each conversion.

##### Notes
- Runs on Windows, macOS and Linux.
- If a conversion fails, the function stops with FFmpeg's message and the remaining files are not converted.

##### Example Usage
```matlab
% Convert two videos and save them in a chosen folder
fileList = {'/Users/yourname/data/video1.avi', '/Users/yourname/data/video2.avi'};
batchConvertVideos(fileList, '/Users/yourname/ConvertedVideos');

% Pick the files; the outputs go to the folder of the first one
batchConvertVideos();
```
