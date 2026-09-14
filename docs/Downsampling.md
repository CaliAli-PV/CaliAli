# Downsampling and Conversion to MAT Format <a id="downsampling"></a>

The first step is converting raw videos into the `.mat` format used by CaliAli, with optional spatial and temporal downsampling.

Run:

```matlab
CaliAli_options = CaliAli_downsample(CaliAli_options);
```

For large videos, use batch downsampling:

```matlab
CaliAli_options = CaliAli_downsample(CaliAli_options);
```

`CaliAli_downsample()` reads in chunks, so memory use does not grow with recording length, and preserves the source datatype of the recording.

!!! success "Output File"
    This step creates `*_ds.mat` files. For naming and save-location details, see [FAQ output naming](FAQ.md#output-files).


!!! danger "What if my video sessions are split into multiple video files (common for UCLA recordings)?"
	Data acquired with the UCLA Miniscope is often divided into multiple `.avi` videos. Select the entire folder instead of individual files so CaliAli concatenates all segments from the same session into one `.mat` file.
	Learn more in [Processing Split Data](Processing_split_data.md).

---

=== "Next"
After finishing downsampling you can proceed to [Motion Correction](Motion_correction.md)
