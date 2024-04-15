# Preprocessing



## Downsampling and conversion to .h5 format <a id="downsampling"></a>

The first step in the CaliAli pipeline is to convert the raw video format into the .h5 format used by CaliAli. This step is done together with spatial downsampling.

!!! Bug "Temporal downsampling"

	CaliAli currently does not support temporal downsampling. Use alternative methods prior to running these steps

Choose your source data type and follow the following steps:

The function used to downsample video sessions would depende on the format of the source data:

=== ".avi"
	``` matlab
	Downsample_avi(ds_f, outpath, theFiles)	
	%% Input variables are described bellow
	```
=== ".tiff"
	``` matlab
	Downsample_tiff(ds_f, outpath, theFiles)	
	
	```
=== ".isdx (Inscopix)"
	``` matlab
	Downsample_inscopix(ds_f, outpath, theFiles)
	%% Input variables are described bellow	
	```
	
	!!! Warning
		Note that this requires installing the Inscopix Data Processing software. 
		By defalt this funciton search for the Inscopix path in 'C:\Program Files\Inscopix\Data Processing'. If this path is not found, a folder selection dialog box will be called.

	
	
	
	
### Input Arguments:

-	ds_f (optional): Downsampling factor. Default is 1 (no downsampling).
-	outpath (optional): Output path for saving downscaled video files. If not provided, the files will be saved in the same directory as the input files.
-	theFiles (optional): Cell array containing paths to video files. If not provided, a file picker dialog will open to select video files interactively.	
	
