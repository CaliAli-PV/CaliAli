### extract_slow_traces {#extract_slow_traces}

```matlab
function out = extract_slow_traces(neuron, varargin)
```

#### Description
extract_slow_traces: Reads traces that keep slow activity, using the neurons a standard extraction found. Use it when slow activity is what you want to study; see [Slow signals](../extraction.md#slow).

The extraction removes activity slower than a few seconds. This function leaves the extraction as it is and reads the traces again from the motion-corrected videos, which were never detrended:

1. Each motion-corrected session gets the same crops, translation and non-rigid warps the alignment applied, so it lines up with the footprints.
2. Every frame is projected onto all the footprints together, so overlapping neurons do not share each other's activity.
3. The median of each trace within each session is its baseline (`F0`), and is subtracted.

No background model is fitted, because CNMF-E's background model can take a neuron's slow activity away. With `'background', 'ring'`, the changes of the mean of a ring around each neuron are subtracted instead, with every neuron left out of every ring.

The motion-corrected videos must still be where the alignment read them. Nothing in `neuron` is changed.

##### Function Inputs:
| Parameter Name | Type    | Description                                 |
|---------------|---------|---------------------------------------------|
| neuron        | CNMF-E neuron object, or path | Output of [CaliAli_cnmfe()](CaliAli_cnmfe.md#CaliAli_cnmfe), or the path to a saved extraction. |
| 'background'  | string  | (Optional) `'none'` (default) or `'ring'`. |
| 'ring_factor' | double  | (Optional) Fraction of the ring's changes subtracted. Default `0.7`. |
| 'ring_radius' | 1 x 2   | (Optional) Inner and outer distance of the ring from the neuron, in pixels. Default `[gSig, 5*gSig]`. |
| 'CaliAli_options' | struct | (Optional) Options to use instead of `neuron.CaliAli_options`. |

##### Function Outputs:
| Field | Description |
|-------|-------------|
| traces | Neurons x frames, in the units of the motion-corrected video, with each session's baseline removed. |
| dff | `traces ./ F0`. `F0` includes the background under the neuron. |
| F0 | Neurons x sessions: the baseline of each trace. |
| frames_per_session | Frames in each session. |
| ids | `neuron.ids`: which neuron each row is. |
| match | How well the fast part of the traces matches the extraction's `C_raw` (median correlation). A low value means the neurons do not line up with this video, and a warning is shown. |

##### Example usage:
```matlab
neuron = load('path/to/extraction.mat').neuron;
slow = extract_slow_traces(neuron);
plot(slow.dff(1, :))
```
