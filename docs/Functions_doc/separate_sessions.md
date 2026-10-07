### separate_sessions {#separate_sessions}

#### Syntax
```matlab
function S = separate_sessions(data, F, bin, sf)
```

#### Description
Splits traces from a multi-session extraction back into one piece per session, and optionally bins them.

CaliAli extracts all sessions as one concatenated recording. `separate_sessions` cuts `data` back into sessions using the number of frames in each session, which CaliAli stores in `neuron.CaliAli_options.inter_session_alignment.F`.

##### Function Inputs:
| Parameter Name | Type   | Description |
|----------------|--------|-------------|
| data | Matrix | One row per neuron and one column per frame, such as `neuron.S` or `neuron.C_raw`. |
| F    | Vector | (Optional) Number of frames in each session: `neuron.CaliAli_options.inter_session_alignment.F`. If omitted or empty (`[]`), you are asked to select the `_Aligned.mat` file or the workspace saved after CNMF-E, and `F` is read from it. |
| bin  | Scalar | (Optional) Bin size in seconds. The values within each bin are summed. Default `0` (no binning). |
| sf   | Scalar | (Optional) Sampling frequency (frames per second) used for binning. Default `1`. |

##### Function Outputs:
| Parameter Name | Type   | Description |
|----------------|--------|-------------|
| S | Cell array | One cell per session, in recording order. Each cell has one row per neuron and one column per frame (or per bin). |

##### Example usage:
```matlab
F = neuron.CaliAli_options.inter_session_alignment.F;
S = separate_sessions(neuron.S, F);            % deconvolved activity per session
S = separate_sessions(neuron.S, F, 1, 10);     % summed in 1 s bins, recorded at 10 fps
S = separate_sessions(neuron.C_raw);           % select the file that holds F
S = separate_sessions(neuron.S, [], 1, 10);    % select the file, then bin
```
