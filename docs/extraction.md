# Calcium Signal Extraction with CaliAli

After confirming [alignment quality](alignment.md#eval), you can proceed to CNMF-E extraction.

## Step 1: Set initialization thresholds <a id="gui"></a>

Use the initialization GUI to set `min_corr` and `min_pnr`:

```matlab
CaliAli_set_initialization_parameters(CaliAli_options)
Check_initialization_parameters(CaliAli_options)
```

Adjust thresholds if the seed preview is too sparse or too dense.

## Step 2: Run CNMF-E <a id="ecs"></a>

Run:

```matlab
CaliAli_cnmfe()
```

This opens a file selector and processes one file at a time. For scripted usage without a picker, see [FAQ](FAQ.md#cnmfe-no-picker).

??? question "How does CaliAli deconvolve calcium signals?"
	CaliAli employs the original FOOPSI method with an AR(1) autoregressive model for initialization and matrix factorization (which is faster). During the final post-processing of traces, a thresholded FOOPSI approach with an AR(2) model is utilized (which is slower but more accurate). Learn more in the [OASIS documentation](https://github.com/zhoupc/OASIS_matlab/blob/master/document/FOOPSI.md#brief-summary-of-the-deconvolution-problem).

During extraction, CaliAli writes checkpoint files you can reload to continue analysis.

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

!!! tip "You can easily monitor the extracted calcium transients by running [view_traces(neuron)](Functions_doc/view_traces.md)"
		
		
## Post-processing detected components

CaliAli includes a GUI to label false positives. After loading `neuron` from a checkpoint:

```matlab
ix = postprocessing_app();
neuron.delete(ix);
```

You can inspect flagged components with `neuron.viewNeurons(find(ix), neuron.C_raw);`.

## Merging components

After deleting false positives, you can merge overlapping components:

```matlab
neuron.merge_high_corr(1, [0.1, 0.3, -inf]);
```

!!! tip "Note that you can create a new checkpoint at any point running `save_workspace(neuron);`"

## Picking Neurons from Residual <a id="residual"></a>

Some neurons may remain un-extracted after the first pass. To recover candidates, run [`manually_update_residuals()`](Functions_doc/manually_update_residuals.md#manually_update_residuals).

## Preparing extracted signals for analysis

CaliAli performs final detrending and noise scaling automatically at the end of the pipeline. Related functions:

- [detrend_Ca_traces()](Functions_doc/detrend_Ca_traces.md#detrend_Ca_traces) 
- [scale_to_noise()](Functions_doc/scale_to_noise.md#scale_to_noise) 
- [postprocessDeconvolvedTraces()](Functions_doc/postprocessDeconvolvedTraces.md#postprocessDeconvolvedTraces) 

=== "CONGRATULATIONS!"
You have successfully extracted neuronal signals using CaliAli. Don't forget to save the results with `save_workspace(neuron)`
	
