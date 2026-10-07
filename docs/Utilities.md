## Separate Data from Different Sessions <a id="separate"></a>

Splits traces from a multi-session extraction back into one piece per session, and optionally bins them.

### Syntax:

```matlab
S = separate_sessions(data, F, bin, sf)
```

### Description:
CaliAli extracts all sessions as one concatenated recording. This function cuts `data` back into sessions using the number of frames in each session (`F`), which CaliAli stores in `neuron.CaliAli_options.inter_session_alignment.F`. If `F` is not provided, you are asked to select the `_Aligned.mat` file or the workspace saved after CNMF-E, and `F` is read from it. The data can be optionally binned using the specified bin size (bin) and sampling frequency (sf).

### Inputs:

-	***data:*** Matrix with one row per neuron and one column per frame, such as `neuron.S` or `neuron.C_raw`.

-	***F (optional)***: Number of frames in each session (`neuron.CaliAli_options.inter_session_alignment.F`). If not provided or empty (`[]`), the user will be prompted to select a file.

-	***bin (optional)***: Bin size in seconds. The values within each bin are summed. If set to 0, no binning is applied. Default is 0 if not specified.

-	***sf (optional)***: Sampling frequency (frames per second) used when binning the data. Default is 1 if not specified.

### Outputs:

-	***S***: Cell array with one cell per session, in recording order. Each cell has one row per neuron.

### Example Usage:

```matlab
% Separate spike data with default bin size and sampling frequency (no binning)
S=separate_sessions(neuron.S, neuron.CaliAli_options.inter_session_alignment.F);

% Separate spike data with 1s bin considering Sampling frequency of 10.
S=separate_sessions(neuron.S, neuron.CaliAli_options.inter_session_alignment.F,1,10);

% Separate raw Calcim traces data with default bin size and sampling frequency (no binning)
S=separate_sessions(neuron.C_raw, neuron.CaliAli_options.inter_session_alignment.F);
```

See also the [separate_sessions](Functions_doc/separate_sessions.md#separate_sessions) reference page.

## Simulate Calcium Imaging Videos <a id="simulate"></a>

Use the open-source [Simulate_Ca_Imaging_video](https://github.com/vergaloy/Simulate_Ca_Imaging_video) toolbox to generate synthetic datasets that mimic one-photon miniscope recordings. With a single configuration file you can specify:

- Field of view dimensions (spatial resolution) and frame count to match your target memory footprint.
- Number of neurons, soma size distribution, firing statistics, and neuropil background.
- Motion trajectories (rigid or drifting), intermittent occlusions, and shot/Poisson noise.
- Acquisition parameters such as frame rate and signal-to-noise ratio.

Exported videos share the same layout as CaliAli demo sessions, making them ideal for benchmarking new parameter presets, testing automatic batch sizing, or teaching the workflow without sharing animal data. Refer to the repository README for installation instructions and example scenarios (`low_memory`, `high_density`, `drift_only`, etc.).

## Other Functions <a id="of"></a>

### Save Workspace

```matlab
save_workspace(neuron);
```

### Updating Paths for Video and MAT Files <a id="update_path"></a>

If you've changed the location of the videos and files generated during the analysis, you'll need to run the following function and select the new 'source_extraction' folder.

```matlab
 neuron=update_folder_path(neuron);
save_workspace(neuron);
```

### Plot Neuron Contours <a id="coor"></a>

```matlab
%% To visualize neurons contours:
neuron.Coor=[]  

%% Plot over PNR image:
   neuron.show_contours(0.9, [], neuron.PNR, 0);  %PNR

%% Plot over correlation image:
   neuron.show_contours(0.6, [], neuron.Cn,0);   %CORR

%% Plot over PNR.Corr image:
  neuron.show_contours(0.6, [], neuron.Cn.*neuron.PNR,0); %PNR*CORR

%% Plot over neuron footprints:
 A=neuron.A;A=full(A./max(A,[],1)); A=reshape(max(A,[],2),[size(neuron.Cn,1),size(neuron.Cn,2)]);
 neuron.show_contours(0.6, [], A, 0);
```
