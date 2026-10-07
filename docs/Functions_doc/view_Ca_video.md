### view_Ca_video {#view_Ca_video}

```matlab
function view_Ca_video(V)
```

#### Description
Interactive visualization of calcium imaging video with playback controls.

##### Function Inputs:
| Parameter Name | Type    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| V             | 3D array | (Optional) Video to display (height × width × frames). If omitted, a file picker opens to select a `.mat` file, and its video (`Y`) is loaded. |

##### Function Outputs:
None (displays the selected video interactively).

##### Example usage:
```matlab
view_Ca_video();     % pick a .mat file (e.g. *_mc.mat, *_det.mat or *_Aligned.mat)
view_Ca_video(Y);    % display a video already in the workspace
```

To reproduce video data stored in the `.mat` files, use the `view_Ca_video()` function and select the desired `.mat` file for monitoring(1).
{ .annotate }

1.	Code modified from Joao Henriques (2024). [Figure to play and analyze videos with custom plots on top](https://www.mathworks.com/matlabcentral/fileexchange/29544-figure-to-play-and-analyze-videos-with-custom-plots-on-top) , MATLAB Central File Exchange. 

![video_app](../files/video_app.gif)


This app includes the following functionalities:

-	++enter++ 	Play/Stop the video.
-	++back++	Play/Stop the video at a faster speed.
-	++left++/++right++	 Advance/go back one frame. Alternatively, you can use the scroll bar at the bottom of the screen.
-	++page-down++/++page-up++	Advance/go back 30 frames.
-	++home++/++end++	Go to the first/last frame.
-	`Contrast` button (top left)	Adjust the contrast of the video.

???+ tip "Adjusting the contrast"
	Click the `Contrast` button, set the display range in the contrast window, and then close that window with the `[x]` button at its upper right corner. The new range is applied to all frames. Do not use the `Adjust Data` button of the contrast window.
