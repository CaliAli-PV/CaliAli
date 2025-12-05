### play_movie {#play_movie}

```matlab
function Mov=play_movie(neuron,batch_num)
```

#### Description
`play_movie` builds and plays a diagnostic movie from a CNMF-E `neuron` object. It loads a block of frames (default frames 1–1000), reconstructs the denoised signal and background (optionally on GPU), overlays colorized spatial components, and concatenates raw, background, background-subtracted, component, and residual views for side-by-side inspection.

##### Function Inputs:
| Parameter Name | Type | Description |
|---------------|------|-------------|
| neuron | CNMF-E neuron object | Contains `options.d1/d2`, spatial footprints `A`, temporal traces `C`, `load_patch_data`, and background helpers. |
| batch_num | Integer (optional) | Index selecting the frame window in `fn` (default `1`, i.e., frames 1–1000 unless `fn` is edited). |

##### Function Outputs:
| Parameter Name | Type | Description |
|---------------|------|-------------|
| Mov | 4-D array | Concatenated movie showing raw data, estimated background, background-subtracted frames, colorized component reconstructions, and residuals; also played via `implay`. |

##### Example usage:
```matlab
Mov = play_movie(neuron);      % review first 1000 frames
```

##### Notes:
- Automatically uses GPU computation when a compatible device is available.
- Update the internal `fn` frame breaks if you need to inspect a different time span or multiple batches.
- The automatic playback uses `implay(Mov*4)`, which multiplies intensities fourfold and clips values to the display range; this makes detected neurons easier to see but can exaggerate noisy signals. For an unboosted view, run `implay(Mov)` instead.
