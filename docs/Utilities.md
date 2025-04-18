## Separate Data from Different Sessions <a id="separate"></a>

Separates data into sessions based on frame information and optionally bins the data.

### Syntax:

```matlab
S = separate_sessions(data, F, bin, sf)
```

### Description:
This function separates data into sessions based on provided frame information (F). If F is not provided, the function prompts the user to select a file containing frame data. The data can be optionally binned using the specified bin size (bin) and sampling frequency (sf).

### Inputs:

-	***data:*** Matrix of data to be separated into sessions.

-	***F (optional)***: Frame information used to define intervals for separating sessions. If not provided, the user will be prompted to select a file.

-	***bin (optional)***: Bin size for binning the data. If set to 0, no binning is applied. Default is 0 if not specified.

-	***sf (optional)***: Sampling frequency used when binning the data. Default is 1 if not specified.

### Outputs:

-	***S***: Cell array containing separated session data.

### Example Usage:

```matlab
% Separate spike data with default bin size and sampling frequency (no binning)
S=separate_sessions(neuron.S, neuron.CaliAli_opt.F);

% Separate spike data with 1s bin considering Sampling frequency of 10.
S=separate_sessions(neuron.S, neuron.CaliAli_opt.F,1,10);

% Separate raw Calcim traces data with default bin size and sampling frequency (no binning)
S=separate_sessions(neuron.C_raw, neuron.CaliAli_opt.F);
```

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

