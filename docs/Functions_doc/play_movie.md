### play_movie {#play_movie}

```matlab
function Mov=play_movie(neuron,batch_num)
```

#### Description
`play_movie` builds and plays a diagnostic movie from a CNMF-E `neuron` object. It loads 1000 frames of the recording at a time, reconstructs the denoised signal and background, overlays colorized spatial components, and concatenates raw, background, background-subtracted, component, and residual views for side-by-side inspection.

##### Function Inputs:
| Parameter Name | Type | Description |
|---------------|------|-------------|
| neuron | CNMF-E neuron object | Contains `options.d1/d2`, spatial footprints `A`, temporal traces `C`, `load_patch_data`, and background helpers. |
| batch_num | Integer (optional) | Which 1000 frames to show: `1` (default) for frames 1–1000, `2` for 1001–2000, and so on. The last part may be shorter. |

##### Function Outputs:
| Parameter Name | Type | Description |
|---------------|------|-------------|
| Mov | 4-D array | Concatenated movie showing raw data, estimated background, background-subtracted frames, colorized component reconstructions, and residuals; also played via `implay`. |

##### Example usage:
```matlab
Mov = play_movie(neuron);      % frames 1-1000
Mov = play_movie(neuron, 2);   % frames 1001-2000
```

##### Notes:
- Uses the GPU when MATLAB can use one (this needs the Parallel Computing Toolbox and a supported GPU); otherwise it runs on the CPU.
- After CNMF-E the traces in `neuron` are in noise units. They are converted back to the movie's intensity scale for this display, so the component and residual panels can be compared with the raw data.
- The automatic playback uses `implay(Mov*4)`, which multiplies intensities fourfold and clips values to the display range; this makes detected neurons easier to see but can exaggerate noisy signals. For an unboosted view, run `implay(Mov)` instead.
