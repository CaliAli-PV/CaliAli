# Extraction of Calcium Traces with CaliAli

After confirming that no errors occur during session alignment and concatenation, you can proceed to extract neural signals from the concatenated video sessions or from individual sessions.

This process involves two steps:

1. **Select Extraction Parameters for Each Session**: Utilize a graphic user interface to set initialization thresholds.
   
2. **Run the CaliAli Extraction Module**: Execute the CaliAli extraction module to extract neural signals.


## Select Extraction Parameters <a id="cnmfapp"></a>

The extraction of calcium signals relies on an initial estimation of neuron locations based on two key projections: the correlation image (showing pixel correlations) and the peak-to-noise ratio (PNR) image (highlighting active regions in the video). To accurately identify candidate neurons, specific minimum correlation and PNR thresholds must be defined. These thresholds are essential for distinguishing genuine neuron activity from background noise and signal fluctuations.

CaliAli offers a graphical user interface (GUI) for setting these thresholds visually.

You can use this GUI by running the following code:

```CNMFe_app```

This will open a window that allows the user to choose one or more `.h5` file for processing:

![load_cnmf_app](files/load_cnmf_app.gif)

For each loaded file the user can modify the following parameters:

1.	PNR threshold (PNR)
2.	Correlation threshold (Corr)
3.	Neuron Filter size(gSig) (1).
	{ .annotate }
	
	1.	This parameter should match the settings used in previous steps. This will not be needed in future updates.
	
4.	Frame rate

To visually set the PNR and Corr. threshold press the `Get` button higlighted in green.

![load_cnmf_app_thr](files/load_cnmf_app_thr.gif)

!!! Bug
	Sometimes, the MATLAB AppDesigner app may not render panels correctly. This is a MATLAB bug. If this happens, just close and reopen the window to fix the issue.

In the opened window, you will find three images displayed: the PNR image, the correlation image, and their point-wise product. Red dots overlaid on these images represent candidate neurons or "seed pixels". Below these images, there are two spinners that control the PNR and correlation thresholds. Adjusting these thresholds will change the number of seed pixels detected.


![adjust_thr](files/adjust_thr.gif)

Additionally, you have the option to manually draw a mask to exclude specific regions within the field of view:

![draw_mask](files/draw_mask.gif)

!!! Note
	Currently you can only draw the mask in the correlation image.
	
Once satisfied with the results press the `Ok!` button.
This will automatically update the parameters for the choosen file with the new thresholds. 

After setting the PNR, Corr, gSig, and Frame rate parameters press `Done!`

## Motion correction <a id="mc"></a>

