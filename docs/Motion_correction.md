Following video downsampling, it is necessary to correct motion artifacts in each individual session.

For this we use the following function.
``` matlab
CaliAli_options=CaliAli_motion_correction(CaliAli_options);
```	
!!! success "Output File"
    Running this function produces a `.mat` file with the `_mc` tag, containing both the motion corrected video data and the `CaliAli_options` structure. By default, the output file name matches the input video, and the save path defaults to the location of the input video. A typical file name may be `vid_01_ds_mc.mat`. 
    

??? Bug  "Limitations of the non-rigid registration module"
	This code is experimental and may introduce undesired deformations when adjusting for non-rigid deformation.
	
??? Info "How long it takes to motion correct videos?"
    - Rigid: ~ [5,000 frames in ~2 minutes on a modern CPU.]("At a resolution of 300x300 pixels")
	- Non-rigid: [is substantially slower processing around ~10 frames per second. A new non-rigid model will be implemented soon]("At a resolution of 300x300 pixels")

???+ danger "Important"
	Ensure to visually inspect the motion-corrected video before proceeding to the next step: [**view_Ca_video()**](Functions_doc/view_Ca_video.md#view_Ca_video)

=== "Next"	
After finishing downsampling and motion correction you can proceed to [Inter-session Alignment](alignment.md)







