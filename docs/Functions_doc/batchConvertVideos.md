### batchConvertVideos {#batchConvertVideos}

# batchConvertVideos

#### 📌 Syntax
```matlab
batchConvertVideos(fileList, outputFolder)
```

## 📌 Description
This function converts a list of AVI files into **lossless grayscale MP4 files** using **FFmpeg**.  
It assumes that the `ffmpeg` executable is located in the same directory as the function file.  

If no input list is provided, the function prompts the user to select files.  
The converted videos will be saved in the specified output folder or the same directory as the input files.

---

####  📌 Function Inputs
| Parameter Name  | Type       | Description  |
|----------------|------------|-------------|
| `fileList`     | `cell array` | A list of input video file paths. If not provided, a file picker will be displayed to select `.avi`, `.mp4`, `.m4v`, `.tif`, `.tiff`, or `.isxd` files. |
| `outputFolder` | `string`    | The directory where the converted MP4 files will be saved. If not specified, the converted files are saved in the same directory as the input videos. |

---

####  📌 Function Outputs
This function does **not** return any values but:
- Converts each input video to a **lossless grayscale MP4 file**.
- Saves the output files in the **specified output folder**.
- Displays messages confirming the successful conversion.

---

####  📌 Dependencies
- **FFmpeg** must be in the same directory as the function file. This is included with this code.
- The function uses `system` commands to execute FFmpeg.

---

#### 📌 Example Usage
```matlab
% Convert selected files and save them in a custom output folder
fileList = {'video1.avi', 'video2.avi'};
outputFolder = 'C:\ConvertedVideos';
batchConvertVideos(fileList, outputFolder);
```

```matlab
% Convert files by selecting them manually and saving in the same directory
batchConvertVideos();
```

---

#### 📌 Error Handling
- If **FFmpeg** is missing, the function will fail when calling `system(command)`.
- If an invalid file is provided, FFmpeg may return an error message.
- If conversion fails, an error message will be displayed showing the reason.

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
