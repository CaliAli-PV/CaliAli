# CaliAli Usage

## System Requirement <a id="requirement"></a>
CaliAli runs in `MATLAB` and requires the following toolbox:
```
-	Signal Processing Toolbox
-	Image Processing Toolbox
-	Statistics and Machine Learning Toolbox'
-	Parallel Computing Toolbox
```
### Hardware

CaliAli autoamtically runs in batch mode, requiring only sufficient RAM to handle the largest imaging session and storing final outputs (less than 2GB if the largest session is 180x260 pixels and 3000 frames).

### Other requirements

!!! note "Process Inscopix data"
	To process Inscopix data, the [Inscopix Data Processing software](https://inscopix.com/software-analysis-miniscope-imaging/) needs to be installed.
	
!!! note "Process [UCLA miniscope](http://miniscope.org/index.php/Main_Page) data on Windows" 
	Matlab does not have the necessary codecs to process `.avi` files. You need to download and install the [K-lite Codec Pack](https://codecguide.com/download_kl.htm).

## Installation <a id="installation"></a>
Installation should take a few minutes:

-	Download/clone the [Git](https://github.com/CaliAli-PV/CaliAli) repository of the codes
-	Add CaliAli to the MATLAB path.


![Alt Text](files/Add_to_path.gif)