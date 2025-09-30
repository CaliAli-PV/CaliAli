### view_Ca_video {#view_Ca_video}

```matlab
function view_Ca_video()
```

#### Description
Interactive visualization of calcium imaging video with playback controls.

##### Function Inputs:
| Parameter Name | Type    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| Neuron           | CNMF-E neuron object | Output of CNMF-E and CaliAli_cnmf()    |

##### Function Outputs:
None (displays the selected video interactively).

##### Example usage:
```matlab
view_Ca_video();
```

To reproduce video data stored in the `.mat` files, use the `view_Ca_video()` function and select the desired `.mat` file for monitoring(1).
{ .annotate }

1.	Code modified from Joao Henriques (2024). [Figure to play and analyze videos with custom plots on top](https://www.mathworks.com/matlabcentral/fileexchange/29544-figure-to-play-and-analyze-videos-with-custom-plots-on-top) , MATLAB Central File Exchange. 

![video_app](../files/video_app.gif)


This app includes the following functionalities:

-	++enter++ 	Play/Stop the video.
-	++back++	Play/Stop the video at 3x speed.
-	++left++/++right++	 Advance/go back one frame. Alternatively, you can use the scroll bar at the bottom of the screen.
-	++page-down++/++page-up++	Advance/go back 30 frames.
-	++c++	Adjust contrast settings in the video.

???+ bug
	When adjusting the contrast of the video, avoid using the `Adjust contrast` button. Instead, simply close the window by clicking the `[x]` button at the upper right corner of the screen.