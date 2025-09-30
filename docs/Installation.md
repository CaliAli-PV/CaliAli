# Installation and system requirements

#### System Requirement <a id="requirement"></a>
CaliAli runs in `MATLAB` and requires the following toolbox:
```
-	Signal Processing Toolbox
-	Image Processing Toolbox
-	Statistics and Machine Learning Toolbox'
-	Parallel Computing Toolbox
```
??? Warning "Function requiring MATLAB 2023b"
	One of the [utilities](Functions_doc/BV_app.md#BV_app) included in CaliAli requires 'MATLAB 2023b' due to its use of new functions from MATLAB's AppDesigner. This function is *NOT* essential for running the CaliAli pipeline."
	
##### Windows
CaliAli has been successfully tested on MATLAB versions 2022a and 2023a running on Windows 11.

??? bug "MATLAB 2024a is not compatible with CaliAli on Windows"
	A bug in the 2024a AppDesigner is causing GUI objects to be improperly located within the app's panels, and it is also affecting other functions. This issue does not affect macOS MATLAB or Windows MATLAB 2023b.
	
##### MacOs
CaliAli has been successfully tested on MATLAB 2024a running on macOS Sonoma 14.5. 


##### Linux

CaliAli has not been tested on linux. No anticipated compatibility issues are expected.

### Hardware <a id="hardware"></a>

CaliAli automatically runs in batch mode, requiring only sufficient RAM to handle the largest imaging session and storing final outputs (less than 2GB if the largest session is 180x260 pixels and 3000 frames).

#### Installation <a id="installation"></a>
Installation should take a few minutes:

-	Download/clone the [Git](https://github.com/CaliAli-PV/CaliAli) repository of the codes
-	Add CaliAli to the MATLAB path.


![Add to path](files/Add_to_path.gif)

=== "Next"
Already installed? Proceed to [CaliAli processing steps](Getting_started.md#ps)
