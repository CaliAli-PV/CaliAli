# Installation and system requirements

## System Requirement <a id="requirement"></a>
CaliAli runs in `MATLAB` and requires the following toolbox:
```
-	Signal Processing Toolbox
-	Image Processing Toolbox
-	Statistics and Machine Learning Toolbox'
-	Parallel Computing Toolbox
```
??? Warning "Function requiring MATLAB 2023b"
	One of the [utilities](Utilities.md#bv_app) included in CaliAli requires 'MATLAB 2023b' due to its use of new functions from MATLAB's AppDesigner. This function is *NOT* essential for running the CaliAli pipeline."
	
### Windows
CaliAli has been successfully tested on MATLAB versions 2022a and 2023a running on Windows 11.

??? bug "MATLAB 2024a is not compatible with CaliAli on Windows"
	A bug in the 2024a AppDesigner is causing GUI objects to be improperly located within the app's panels, and it is also affecting other functions. This issue does not affect macOS MATLAB or Windows MATLAB 2023b.

??? note "Process Inscopix data on Windows"
	To process Inscopix data, the [Inscopix Data Processing software](https://inscopix.com/software-analysis-miniscope-imaging/) needs to be installed.	
	
??? note "Process [UCLA miniscope](http://miniscope.org/index.php/Main_Page) data on Windows" 
	MATLAB does not have the necessary codecs to process compressed .avi files. You need to download and install the [K-lite Codec Pack](https://codecguide.com/download_kl.htm).
	
### MacOs
CaliAli has been successfully tested on MATLAB 2024a running on macOS Sonoma 14.5. 

??? note "Process Inscopix data on Mac"
	At present, CaliAli is unable to convert Inscopix '.isdx' data into '.h5' format on ARM machines. Please convert your data into a compatible format (.h5 , uncompressed avi, or .tiff) using the Inscopix software. 

??? note "Process [UCLA miniscope](http://miniscope.org/index.php/Main_Page) data on MAC"	
		MATLAB cannot process compressed avi format. Be sure to save your videos in uncompressed format  or TIFF. 

### Linux

CaliAli has not been tested on linux. No anticipated compatibility issues are expected.

### Hardware <a id="hardware"></a>

CaliAli automatically runs in batch mode, requiring only sufficient RAM to handle the largest imaging session and storing final outputs (less than 2GB if the largest session is 180x260 pixels and 3000 frames).

## Installation <a id="installation"></a>
Installation should take a few minutes:

-	Download/clone the [Git](https://github.com/CaliAli-PV/CaliAli) repository of the codes
-	Add CaliAli to the MATLAB path.


![Add to path](files/Add_to_path.gif)

=== "Next"
Already installed? Proceed to [Getting started](demo_data.md)