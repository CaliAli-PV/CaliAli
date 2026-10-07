### batchConvertVideos {#batchConvertVideos}

# batchConvertVideos

#### 📌 Syntax
```matlab
batchConvertVideos(fileList, outputFolder)
```

## 📌 Description
This function converts a list of AVI files into **lossless grayscale MP4 files** using **FFmpeg**.  
It uses the `ffmpeg` executable bundled in the same directory as the function file, which runs on macOS only (see Dependencies).  

If no input list is provided, the function prompts the user to select files.  
The converted videos will be saved in the specified output folder or, if none is given, in the folder of the first input file.

---

####  📌 Function Inputs
| Parameter Name  | Type       | Description  |
|----------------|------------|-------------|
| `fileList`     | `cell array` | A list of input video file paths. If not provided, a file picker will be displayed to select `.avi`, `.mp4`, `.m4v`, `.tif`, `.tiff`, or `.isxd` files. |
| `outputFolder` | `string`    | The directory where the converted MP4 files will be saved. If not specified, all converted files are saved in the folder of the first input file. |

---

####  📌 Function Outputs
This function does **not** return any values but:
- Converts each input video to a **lossless grayscale MP4 file**.
- Saves the output files in the **specified output folder**.
- Displays messages confirming the successful conversion.

---

####  📌 Dependencies
- **FFmpeg** must be in the same directory as the function file. A macOS build is included with this code; it runs on Intel and Apple Silicon Macs (on Apple Silicon through Rosetta). No Windows or Linux build is included, so the function does not work on those systems as shipped.
- The function uses `system` commands to execute FFmpeg.

---

#### 📌 Example Usage
```matlab
% Convert selected files and save them in a custom output folder
fileList = {'video1.avi', 'video2.avi'};
outputFolder = '/Users/yourname/ConvertedVideos';
batchConvertVideos(fileList, outputFolder);
```

```matlab
% Select files manually; outputs go to the folder of the first selected file
batchConvertVideos();
```

---

#### 📌 Error Handling
- If **FFmpeg** is missing, the function will fail when calling `system(command)`.
- If an invalid file is provided, FFmpeg may return an error message.
- If a conversion fails, an error showing FFmpeg's message stops the batch; the remaining files are not converted.
- Paths with spaces are not supported: the input files, the output folder and the CaliAli folder must not contain spaces.

---

#### 📌 Process Workflow
1. **Check for input files**: If no `fileList` is provided, the user selects files manually.
2. **Locate FFmpeg**: The function assumes `ffmpeg` is in the same directory.
3. **Prepare output folder**: If `outputFolder` is provided, it creates the directory if it doesn't exist.
4. **Convert each file**:
   - Extracts the filename.
   - Constructs an **FFmpeg command** to convert to **grayscale MP4** with `libx264` (CRF 0).
   - Executes FFmpeg.
5. **Display conversion progress**.
6. **Complete batch processing**.
