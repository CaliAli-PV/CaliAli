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
    - **Rigid**: processes ~5,000 frames in about 2 minutes on a modern CPU. :material-information-outline:{ title="Estimate based on ~300×300 pixel videos." }
	- **Non-rigid**: substantially slower at roughly 10 frames per second. :material-information-outline:{ title="Measured on ~300×300 pixel videos; an updated module is in development." }

!!! tip "Crop after motion correction"
	Use [CaliAli_crop()](Functions_doc/CaliAli_crop.md#CaliAli_crop) to interactively draw a shared region of interest across the motion-corrected sessions. The tool opens representative frames, lets you define the final field of view, and rewrites each `_mc` file in-place so downstream detrending and alignment run on the trimmed data.

???+ danger "Important"
	Ensure to visually inspect the motion-corrected video before proceeding to the next step: [**view_Ca_video()**](Functions_doc/view_Ca_video.md#view_Ca_video)

=== "Next"	
After finishing downsampling and motion correction you can proceed to [Inter-session Alignment](alignment.md)




