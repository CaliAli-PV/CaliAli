#### I. Downsampling and Conversion to .mat Format <a id="downsampling"></a>

The first step in the CaliAli pipeline is to convert the raw video format into the .mat format used by CaliAli. This step is done together with spatial and temporal downsampling.

##### Running  [CaliAli_downsample()](Functions_doc/CaliAli_downsample.md#CaliAli_downsample)  would call a file selection windows allowing to process multiple files:

``` matlab
 CaliAli_options=CaliAli_downsample(CaliAli_options);  
```
!!! success "Output File"
    Running this function produces a `.mat` file with the `_ds` tag, containing both the video data and the `CaliAli_options` structure. By default, the output file name matches the input video, and the save path defaults to the location of the input video.
    
??? Question "What formats are supported by CaliAli"
	CaliAli supports `.avi / .m4v / .mp4 / .mkv / .tiff / .isdx (Inscopix)`. However there are some limitations and requirements depending on the operative system that you are using:
	
	=== "Windows"
		Matlab does not have the necessary codecs to process `.avi` files in windows. You need to download and install the [K-lite Codec Pack](https://codecguide.com/download_kl.htm) to be able to run this code.
			
		??? Warning "Inscopix Users: Please note the following system-specific instructions"
			This requires installing the Inscopix Data Processing software. By default, the function searches for the Inscopix path in  `C:\Program Files\Inscopix\Data Processing `.  If that path is not found, a folder selection dialog box will appear.
	
    === "Mac"
         - At present, CaliAli is unable to convert Inscopix '.isdx' data into '.h5' format on ARM machines. Please convert your data into a compatible format (.h5 , uncompressed avi, mp4) using the Inscopix software. 
         - MATLAB cannot process compressed avi format. Be sure to save your videos in uncompressed format. You can convert your videos to .mp4 with [batchConvertVideos()](Functions_doc/batchConvertVideos.md)
         
    === "Linux"
         We have not tested CaliAli in Linux system yet but it is in our to do list.

!!! Danger "What if my video sessions are split into multiple video files (common for UCLA recordings)?"
	Data acquired with the UCLA Miniscope is often divided into multiple `.avi` videos. Instead of selecting individual `.avi` files, you can choose an entire folder. CaliAli will automatically search for all files matching the [file_extension](Parameters_index.md) defined in the `CaliAli_options` structure within the selected folder and treat them as segments of the same session. These files will then be concatenated into a single `.mat` file for streamlined processing.
	Lean more [here](Processing_split_data.md).
	
??? Question "Can I automate this process without manually selecting files?"
    Yes! The `CaliAli_options` structure contains subfields like `input_files` and `output_files`, which allow you to programmatically automate file processing. You can pass a cell array of file paths to `input_files` and use the cell array from `output_files` as input for the next module.
    For example, running:
    	
    ```matlab
     CaliAli_options.motion_correction.input_files = CaliAli_options.downsampling.output_files;
     ```
     
     will automatically set the downsampling output files as the input for the motion correction module, skipping the file selection dialog entirely. This approach is especially useful when processing multiple files overnight 😴.


??? Question "What if I want to change parameters in the middle of the analysis?" 
	If you want to change parameters in the `CaliAli_options` structure, you can simply modify its values:
			
	`CaliAli_options.motion_correction.input_files = CaliAli_options.downsampling.output_files;`
    
    However, note that some parameters are used by different modules. For example, `BVsize` is utilized during both motion correction and inter-session alignment. To replace all instances of `BVsize`, you can run:  
    `CaliAli_options = CaliAli_parameters(CaliAli_options, 'BVsize', BVsize);`
    
    Now, if you want to change parameters in the `CaliAli_options` stored in multiple files, you can run [CaliAli_update_parameters()](Functions_doc/CaliAli_update_parameters.md#CaliAli_update_parameters), which will update all the selected files.

---

=== "Next"	
After finishing downsampling you can proceed to [Motion Correction](Motion_correction.md)		


