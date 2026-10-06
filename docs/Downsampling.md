# Downsampling and Conversion to MAT Format <a id="downsampling"></a>

The first step is converting raw videos into the `.mat` format used by CaliAli, with optional spatial and temporal downsampling.

Run:

```matlab
CaliAli_options = CaliAli_downsample(CaliAli_options);
```

There is nothing separate to call for large recordings. `CaliAli_downsample()` always reads in chunks, so memory use does not grow with the length of the recording. How many frames it holds at once is set by [`batch_sz`](Low_memory.md).

!!! success "Output File"
    This step creates `*_ds.mat` files. For naming and save-location details, see [FAQ output naming](FAQ.md#output-files).

## Bit depth <a id="output-class"></a>

CaliAli stores videos as 16-bit by default, which keeps the full brightness range of 8-, 12- and 16-bit cameras. You can change this with `output_class` in your parameter file:

```matlab
params.output_class = 'uint16';   % default; also 'uint8' or 'uint32'
```

`'uint8'` halves the file size but can clip bright signals; CaliAli warns you when that happens.

## Camera defects <a id="defects"></a>

While downsampling, CaliAli checks each recording for dead pixels, dropped frames and padded borders left by other software, and repairs them before motion correction. This is on by default and needs no setup; when something is found, the command window reports it (for example, `sensor defects: 3 dead pixels, border 0 px`).

| Setting | Default | Use |
|---------|---------|-----|
| `repair_defects` | `true` | Set to `false` to skip the check entirely. |
| `repair_borders` | `true` | Set to `false` to keep constant borders at the frame edge. |
| `dead_pixel_factor` | `0.1` | Raise it if dead pixels are missed; lower it if normal pixels are being flagged. |


!!! danger "What if my video sessions are split into multiple video files (common for UCLA recordings)?"
	Data acquired with the UCLA Miniscope is often divided into multiple `.avi` videos. Select the entire folder instead of individual files so CaliAli concatenates all segments from the same session into one `.mat` file.
	Learn more in [Processing Split Data](Processing_split_data.md).

---

=== "Next"
After finishing downsampling you can proceed to [Motion Correction](Motion_correction.md)
