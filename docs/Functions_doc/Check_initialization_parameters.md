### Check_initialization_parameters {#Check_initialization_parameters}

```matlab
function Check_initialization_parameters(CaliAli_options)
```

#### Description
`Check_initialization_parameters` previews how many neurons will be seeded before running CNMF-E. It inspects the stored correlation (`Cn`) and peak-to-noise (`PNR`) projections, applies the current `min_corr`, `min_pnr`, and `seed_mask` thresholds, and reports the total count while overlaying the candidate locations on the correlation image. Use this helper after alignment to decide whether initialization parameters need adjustment.

#### Function Inputs
| Name | Type | Description |
|------|------|-------------|
| `CaliAli_options` | struct | Options that already contain the correlation (`Cn`) and PNR projections: those returned by `CaliAli_align_sessions`, or loaded from a `_det` or `_Aligned` file. |

#### Behaviour
- The `Cn` and `PNR` projections must already be calculated, by [`CaliAli_align_sessions`](CaliAli_align_sessions.md#CaliAli_align_sessions) (or [`detrend_batch_and_calculate_projections`](detrend_batch_and_calculate_projections.md#detrend_batch_and_calculate_projections) for single files). If they are missing, a warning is printed and you are asked to select the `_Aligned` or `_det` `.mat` file that contains them.
- Computes the local maxima mask used during CNMF-E initialization and applies correlation/PNR thresholds together with the seed mask.
- Displays the correlation image with the proposed seeds highlighted and prints a colour-coded summary of the neuron count.
- Reminds you to re-run [`CaliAli_set_initialization_parameters`](CaliAli_set_initialization_parameters.md#CaliAli_set_initialization_parameters) if the count looks too high or too low.

#### Example Usage
```matlab
CaliAli_options = CaliAli_align_sessions(CaliAli_options);   % calculates Cn and PNR
Check_initialization_parameters(CaliAli_options);              % preview initialization density
```
