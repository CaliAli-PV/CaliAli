### plot_P {#plot_P}

#### Syntax
```matlab
function frame = plot_P(P)
```

#### Description
`plot_P` shows the session projections before and after each alignment step, one session at a time, so you can check the [alignment quality](../alignment.md#eval) visually. The result opens in MATLAB's video player: each frame is one session. Rows are the alignment steps (`Original`, `Translations`, `CaliAli`, and `CaliAli+neurons` if `final_neurons` is enabled); columns are the average frame, the blood vessels, the neurons and the blood vessel + neuron overlay.

##### Function Inputs
| Parameter Name | Type | Description |
|----------------|------|-------------|
| `P` | table | Alignment projections stored in `CaliAli_options.inter_session_alignment.P` by [CaliAli_align_sessions()](CaliAli_align_sessions.md#CaliAli_align_sessions). |

##### Function Outputs
| Name | Type | Description |
|------|------|-------------|
| `frame` | 4D array | RGB images of the figure, one per session (height × width × 3 × sessions). |

##### Notes
- When sessions are well aligned, blood vessels and neurons in the `CaliAli` row stay in place as you step from one session to the next.

##### Example Usage
```matlab
P = CaliAli_options.inter_session_alignment.P;
frame = plot_P(P);
```
