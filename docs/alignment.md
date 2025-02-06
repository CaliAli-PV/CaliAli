#### Inter-Session Alignment and projection calculation <a id="main"></a>


After [motion correction](Motion_correction.md) we have to [calculate relevant projections]("Projections of blood vessels and neurons. These are used for alignment and for neuronal extraction is later stages"), align and concatenate sessions. Alternatively, we can also process individual files independently:

=== "Alignment and Concatenation"
    To achieve this, CaliAli performs the following steps:
    	
       1. **Detrend each imaging session.** 
       2. **Calculate projections of the blood vessels and neurons.** 
       3. **Calculate displacement fields to align sessions using blood vessels and neurons.** 
       4. **Evaluates blood vessel (BV) similarity and switches to neuron-based alignment if necessary.** 
       5. **Apply displacement field to each video session.** 
       6. **Standardized pixels and concatenate aligned videos:** 
       
       This is done by executing;
       ``` matlab
       CaliAli_align_sessions(CaliAli_options);
       ```	
       
    !!! success "Output File"
        Running this function produces a `.mat` file with the `_Aligned` tag, containing the aligned and concatenated video and the `CaliAli_options` structure. By default, the output file name matches the input video, and the save path defaults to the location of the input video. A typical file name may be `'Last_session_name"_ds_mc_Aligned.mat`. This will also create one `.mat` file with the `_det` tag for each input session containing the detrended data and the relevant projections.
    

			
=== "Single File Processing"
     Even if we do not require to align sessions we still need to [calculate relevant projections]("Projections of blood vessels and neurons. These are used for alignment and for neuronal extraction is later stages") that will be used in later stages.
     This is done by executing:
      ``` matlab
        detrend_batch_and_calculate_projections(CaliAli_options);
      ```	
    !!! success "Output File"
        Running this function produces a `.mat` file with the `_det` tag, containing the aligned and concatenated video and the `CaliAli_options` structure. By default, the output file name matches the input video, and the save path defaults to the location of the input video. A typical file name may be `vid_01_ds_mc_det.mat`.


#### Evaluating Alignment Performance: <a id="eval"></a>

##### Console outputs:

While running  [CaliAli_align_sessions()](Functions_doc/CaliAli_align_sessions.md#CaliAli_align_sessions), the command window will display output similar to the following:

```
Blood-vessel similarity score: 5.376
Calculating correlation of the Neurons projections... 
Processing:  100%  |############| 6/6it [00:00:00<00:00:00, 32.27 it/s]
Correlation between Neurons projections is good! 
Lowest spatial correlation: 0.491
``` 

- [The `Blood-vessel similarity score` reflects the usefulness of blood vessels in correcting inter-session misalignments.]("If this value falls below 2.7, CaliAli will issue a warning message and align sessions without relying on blood vessels (alignment dependent on neurons only").

- [The `spatial correlation value` indicates the correlation of the aligned neurons' projections.]("If this value is below 0.2, it may suggest substantial differences in active neurons across sessions, possibly due to displacement in the z-axis.")

##### Post alignment:
To visually confirm the alignment performance, load the `*_Aligned.mat file` in MATLAB:
First, load the alignment options from a saved `.mat` file. 
For the [demo file]("Assuming you Matlab path is the Demo folder") this would be:

```matlab
CaliAli_options = CaliAli_load('v4_mc_ds_Aligned.mat', 'CaliAli_options');
```
Replace `'v4_mc_ds_Aligned.mat'` with the path to your specific file.

You can evaluate the alignment performance by running the following lines:
```matlab
% Get BV-score:
fprintf('BV Score: %.4f\n', CaliAli_options.inter_session_alignment.BV_score);
% Get alignment metrics: Mean Correlation score and Crispness (Higher the
% better)
Alignment_metrics = CaliAli_options.inter_session_alignment.alignment_metrics
plot_alignment_scores(CaliAli_options)

% View aligned projections:
P = CaliAli_options.inter_session_alignment.P;  %extract the aligned projections
frame=plot_P(P); %Create video of the Aligned projections before and after CaliAli.
```

The most important components is the table **P**, which is structured as follow: 

| Column        | Description                             |
| --------------| ----------------------------------------|
| `Original`    | Projections before alignment             |
| `Translation` | Projections after translation           |
| `Multi-Scale` | Projections after multi-scale alignment |
| `Final`       | Projections after final alignment       |

Each column contains a nested table with projections organized as 3D or 4D arrays, representing data from each session:

| Column         | Description                                          |
| ---------------| -----------------------------------------------------|
| `Mean`         | Mean frame of each session                           |
| `BloodVessels` | Blood vessels projection of each session             |
| `Neurons`      | Neuron projections of each session                   |
| `PNR`          | PNR projections of each session                      |
| `BV+Neurons`   | Blood vessels and neurons projection of each session |

You can visualize these projections with the following commands:

``` matlab
P = CaliAli_options.inter_session_alignment.P;  %extract the aligned projections
frame=plot_P(P); %Create video of the Aligned projections before and after CaliAli.
```
![BV+Neurons](files/align_demo.gif)

???+ danger "Important"
	Please visually verify that sessions are correctly aligned. If you detect noticeable displacement in the field of view it means that CaliAli is not suitable for this data.
	
=== "Next"
After finishing inter-session alignment or individual sessions processing you can proceed to [Extract Calcium Traces with CaliAli](extraction.md)