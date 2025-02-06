```matlab
function out=detrend_Ca_traces(nums,obj,F)
```

#### Description
`detrend_Ca_traces`: Removes slow baseline fluctuations from calcium traces.

##### Function Inputs:
| Parameter Name | Type   | Description                |
|---------------|--------|----------------------------|
| `nums`        | double | The window size factor used for median filtering and erosion.|
| `obj`         | matrix | The calcium activity traces (matrix of size [neurons x frames]).|
| `F`           | double | (Optional) The number of frames per batch. Defaults to `size(obj,2)`.|

##### Function Outputs:
| Parameter Name | Type   | Description              |
|---------------|--------|--------------------------|
| `out`         | matrix | The detrended calcium traces with baseline fluctuations removed.|

##### Example usage:
```matlab
out = detrend_Ca_traces(10, neuron.C_raw);
out = detrend_Ca_traces(nums,neuron.C_raw, 1000);
```

## Functionality
- Applies a **median filter** (`medfilt1`) to smooth the signal over `nums*10` frames.
- Refines the baseline using **morphological erosion** (`imerode`).
- Computes **detrended traces** by subtracting the estimated baseline from the original signal.
- Handles **multi-batch datasets** by processing each segment separately and concatenating results if needed.

!!! warning
    - Running this function modifies the temporal traces in a way that makes them unsuitable for further CNMF iterations. If additional CNMF iterations are needed, `neuron=CNMF_CaliAli_update('Temporal',neuron);` must be rerun to restore a compatible state.
    


