# TL;DR: Processing Multi-session Calcium Imaging Data with CaliAli

This section is intended for users who have already read the rest of the documentation and want a general overview of the commands needed to fully process the data.

Run the following functions:

!!! note
	The following functions use the default parameters assuming a frame rate of 10 frames per second.

### 1) Data Downsampling:

=== ".avi / .m4v / .mp4"
	``` matlab
	Downsample_avi(2)	
	```
	
=== ".tiff"
	``` matlab
	Downsample_tiff(2)		
	```	
=== ".isdx (Inscopix)"
	``` matlab
	Downsample_inscopix(4)
	```
	
### 2) Motion Correction:

``` matlab
% Choose the files to motion correct
MC_Batch();
```

### 3) Inter-session Alignment:

``` matlab
% Choose the sessions to align:
align_sessions_CaliAli();

% If it is only one session:
detrend_batch_and_calculate_projections()
```

### 4) Calcium Traces Extraction:

-	Run `CNMFe_app`.
-	Choose the video file with the concatenated data named `<File_name>_Aligned.h5`.
-	Select appropriate initialization parameters.
-	Run `CNMFe_batch(parin)`.

### 5) Optional post-processing

-	Load the `.mat` file with the extracted data.
-	Label false positives with `ix=postprocessing_app(neuron)` 
-	Run `neuron.delete(ix)` to check and delete labeled components. 
-	Run `save_workspace(neuron)` to save results.


