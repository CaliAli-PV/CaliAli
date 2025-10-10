# Calcium Signal Extraction with CaliAli

After confirming that no errors occur during [session alignment and concatenation](alignment.md#main), you can proceed to extract neural signals.

This process involves two steps:

1. **Select Extraction Parameters for Each Session**: Utilize a graphical user interface to set initialization thresholds, then sanity-check the expected neuron count with [`Check_initialization_parameters`](Functions_doc/Check_initialization_parameters.md#Check_initialization_parameters).
   
2. **Run the CaliAli Extraction Module**: Execute the CaliAli extraction module to extract neural signals.
<a id="gui"></a>

???+ info "A GUI for Parameter Selection" 
    The extraction of calcium signals relies on an initial estimation of neuron locations based on two key projections: the correlation image (showing pixel correlations) and the peak-to-noise ratio (PNR) image (highlighting active neurons in the video). To accurately identify candidate neurons, specific minimum correlation and PNR thresholds must be defined. These thresholds are essential for distinguishing genuine neuron activity from background noise and signal fluctuations.

    ***CaliAli offers a graphical user interface (GUI) for setting these thresholds visually.*** Once satisfied, run [`Check_initialization_parameters`](Functions_doc/Check_initialization_parameters.md#Check_initialization_parameters) to confirm the number of seeds that will be passed to CNMF-E; adjust thresholds if the preview looks too sparse or too crowded.

    You can use this GUI by running the following code:  ['CaliAli_set_initialization_parameters()'](Functions_doc/CaliAli_set_initialization_parameters.md#CaliAli_set_initialization_parameters)

#### Extracting Calcium Signals <a id="ecs"></a>

After defining input parameters perform neuronal extraction by running the following command:

```matlab
CaliAli_cnmfe()
```
This will open a file selector dialog and start the neuronal extraction process one file at a time.

#### Overview of the Calcium extraction process

The neuronal extraction process can be described by the following diagram:

``` mermaid
graph TD;
	A[CNMFe_batch] --> B[Distribute data in patches];
	B --> C[Initialization];
	C --> |Checkpoint| D[Update Background];
	D --> E[Update Spatial];
	E --> F[Update Temporal];
	F --> G[Remove False-positives];
	G --> H[Merge Neurons];
	H --> I[Similarity Check];
	I -->|<0.95| D;
	I -->|>0.95<br>Checkpoint| J[Post-process Traces];
	J --> |Checkpoint| K[Manually Remove FP];
	K --> L[Manually Merge Neurons];
	L --> M[Pickup from Residual?];
	M -->|Yes| D;
	M -->|No| Finish;	
	
	O[Optional];
	P[Automatic];
	N[Automatic CNMF];
	
style A fill:none, stroke:none;
style D stroke:#1CC90E, color:#00129A,  stroke-width:2px;
style E stroke:#1CC90E, color:#00129A,  stroke-width:2px;
style F stroke:#1CC90E, color:#00129A,  stroke-width:2px;
style G stroke:#1CC90E, color:#00129A,  stroke-width:2px;
style H stroke:#1CC90E, color:#00129A,  stroke-width:2px;
style N stroke:#1CC90E, color:#00129A,  stroke-width:2px;

style K stroke:#E04C3B, color:#7A6A68,  stroke-width:2px; 
style L stroke:#E04C3B, color:#7A6A68,  stroke-width:2px;
style M stroke:#E04C3B, color:#7A6A68,  stroke-width:2px;
style O stroke:#E04C3B, color:#7A6A68,  stroke-width:2px;
```
During the execution of this code, you will see messages in the command window reflecting the steps depicted above:

```
----------------UPDATE BACKGROUND---------------------------
Processing:  100%  |############| 4/4it [00:00:04<00:00:00, 1.06 it/s]

-----------------UPDATE SPATIAL---------------------------
Processing:  100%  |############| 4/4it [00:00:02<00:00:00, 1.45 it/s]

-----------------UPDATE TEMPORAL---------------------------
Processing:  100%  |############| 4/4it [00:00:05<00:00:00, 1.30 s/it]
Deconvolve and denoise all temporal traces again...
```

??? question "How does CaliAli deconvolve calcium signals?"
	CaliAli employs the original FOOPSI method with an AR(1) autoregressive model for initialization and matrix factorization (which is faster). During the final post-processing of traces, a thresholded FOOPSI approach with an AR(2) model is utilized (which is slower but more accurate). Learn more in the [OASIS documentation](https://github.com/zhoupc/OASIS_matlab/blob/master/document/FOOPSI.md#brief-summary-of-the-deconvolution-problem).

Note that there are three checkpoints during this process: one after Initialization, another after CNMF iterations, and a third after Post-processing of Calcium Traces.

The checkpoint files will be created as follows: <a id="chk"></a>

``` matlab
.
└─ <"file_name">_aligned_source_extraction/
   └─ frames_<"xxx">/
      └─ LOGS_<"DATE">/
         ├─ <"DATE-TIME">.mat "Checkpoint #1"
         ├─ <"DATE-TIME">.mat "Checkpoint #2"
         ├─ <"DATE-TIME">.mat "Checkpoint #3"
```

Loading any of these checkpoint files will load a `neuron` object containing the following properties:

 ``` matlab
	A: [27840×106 double]
	A_prev: [27840×106 double]
	C: [106×4000 double]
	C_prev: [106×4000 double]
	C_raw: [106×4000 double]
	S: [106×4000 double]
	kernel: [1×1 struct]
	b0: {2×4 cell}
	b0_new: [120×232 double]
	...
 ```
 Here the most important properties are:
 
 1. ***A***: Spatial components of neurons stored as a matrix d1*d2xN (1)
	{ .annotate }
	
	1. d1 and d2 are the x and y dimensions of the field of view and N is the number of neurons.
	
2. ***C_raw***: Extracted raw calcium traces stored as a matrix NxT (1)
	{ .annotate }
	
	1. N is the number of neurons and T is the number of frames. Fluorescent signals are expressed as SD above the noise level. This is what we use as raw dF/F0.  

3.	***C***: Denoised Calcium Signals. Same structure as C_raw.
	
4.	***S***: Raising events or Spikes. Same structure as C_raw.	(1)
	{ .annotate }
	
	1. This dataset contains the same information as dataset C, excluding the calculated rise and decay times of the calcium signals. S is recommended for most analyses.
	
!!! tip "You can easily monitor the extracted calcium transients by running [view_traces(neuron)](Functions_doc/view_traces.md)"
	
	
#### Post-processing detected components

CaliAli incorporates a GUI to facilitate the identification of false-positive detections.  After loading the `neuron` object stored in the [Checkpoint files](extraction.md#chk), execute the following function to call this GUI:  [ix=postprocessing_app()](Functions_doc/postprocessing_app.md#postprocessing_app).

This will create a variable `ix` holding the indices of the labeled false-positives.

You can delete these components by running `neuron.delete(ix);`. Alternatively, you can monitor each of these components with `neuron.viewNeurons(find(ix), neuron.C_raw);`.

#### Merging components

After deleting false positives, you can consider merging neurons by manually monitoring neurons that are close by. For this, run`neuron.merge_high_corr(1, [0.1, 0.3, -inf]);`

!!! tip "Note that you can create a new checkpoint at any point running `save_workspace(neuron);`"

#### Picking Neurons from Residual <a id="residual"></a>

Some neurons may remain un-extracted after the initial processing. To extract potentially missed neurons run: [`manually_update_residuals()`](Functions_doc/manually_update_residuals.md#manually_update_residuals)

#### Preparing extracted signals for analysis

CaliAli performs a final detrending and noise scaling of the signals which facilitates posterior analysis. We recommend familiarizing with these two following functions which are executed automatically at the end of the pipeline:

- [detrend_Ca_traces()](Functions_doc/detrend_Ca_traces.md#detrend_Ca_traces) 
- [scale_to_noise()](Functions_doc/scale_to_noise.md#scale_to_noise) 
- [postprocessDeconvolvedTraces()](Functions_doc/postprocessDeconvolvedTraces.md#postprocessDeconvolvedTraces) 

=== "CONGRATULATIONS!"
You have successfully extracted neuronal signals using CaliAli. Don't forget to save the results with `save_workspace(neuron)`
	
