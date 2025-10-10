### Check_initialization_parameters {#Check_initialization_parameters}

```matlab
function Check_initialization_parameters(CaliAli_options)
```

#### Description
`Check_initialization_parameters` previews how many neurons will be seeded before running CNMF-E. It inspects the stored correlation (`Cn`) and peak-to-noise (`PNR`) projections, applies the current `min_corr`, `min_pnr`, and `seed_mask` thresholds, and reports the total count while overlaying the candidate locations on the correlation image. Use this helper after alignment to decide whether initialization parameters need adjustment.

#### Function Inputs
| Name | Type | Description |
|------|------|-------------|
| `CaliAli_options` | struct | Options structure loaded from a `_det` or `_Aligned` file; must contain `inter_session_alignment.Cn/PNR` and CNMF settings. |

#### Behaviour
- Validates that the required `Cn` and `PNR` projections are present.
- Computes the local maxima mask used during CNMF-E initialization and applies correlation/PNR thresholds together with the seed mask.
- Displays the correlation image with the proposed seeds highlighted and prints a colour-coded summary of the neuron count.
- Reminds you to re-run [`CaliAli_set_initialization_parameters`](CaliAli_set_initialization_parameters.md#CaliAli_set_initialization_parameters) if the count looks too high or too low.

#### Example Usage
```matlab
% After running CaliAli_align_sessions, preview initialization density
Check_initialization_parameters(CaliAli_options);
```
