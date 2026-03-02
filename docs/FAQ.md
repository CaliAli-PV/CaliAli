# Frequently Asked Questions

??? Question "Can I run the full pipeline without manually selecting files?"
    Yes. Use the scripted workflow shown in [Getting Started](Getting_started.md#no-gui-workflow).

<a id="downsample-functions"></a>
??? Question "What is the difference between `CaliAli_downsample()` and `CaliAli_downsample_batch()`?"
    `CaliAli_downsample()` is the older, more established implementation.
    `CaliAli_downsample_batch()` is the newer implementation and is designed to handle both chunked and non-chunked processing automatically.

    The long-term plan is to use the batch implementation as the default downsampling path. Both functions are currently kept in the codebase while `CaliAli_downsample_batch()` continues to be validated across more datasets.

    Practical recommendation:

    1. Prefer `CaliAli_downsample_batch()` (especially for large recordings).
    2. If you hit unexpected behavior, fall back to `CaliAli_downsample()` and report the issue.


??? Question "What if my video sessions are split into multiple video files (common for UCLA recordings)?"
    Data acquired with the UCLA Miniscope is often divided into multiple `.avi` videos—select the entire folder instead of individual files.
    CaliAli automatically finds every file matching the configured `file_extension`, treats them as segments from the same session, and concatenates them into a single `.mat` file for streamlined processing.
    Learn more in [Processing Split Data](Processing_split_data.md).

??? Question "What file formats are supported?"
    CaliAli supports common formats including `.avi`, `.m4v`, `.mp4`, `.tif/.tiff`, `.h5`, and `.isxd`.
    See [Installation and system requirements](Installation.md#supported-formats) for platform-specific compatibility notes.

??? Question "CNMF-E fails or stops on large recordings. What should I do?"
    First checks:

    1. Confirm downsampling, motion correction, and alignment completed successfully.
    2. Use the chunked workflow (`CaliAli_downsample_batch`) and set `batch_sz` following [Recommended Parameter Workflow](Parameters.md#parameter-workflow).
    3. Try a smaller numeric `batch_sz`.
    4. Test a shorter subset to isolate which step fails.

    CNMF-E is usually the most memory-intensive stage and may require iterative tuning on very large datasets.

??? Question "CNMF takes too long"
    If CNMF processing is taking too long, the best approach is to increase the spatial downsampling factor.
    Spatial downsampling can drastically reduce computation time.

    Ideally, the field of view after downsampling should be close to `250 x 250` pixels.

    Recommended starting points:

    1. UCLA Miniscope: `2x` spatial downsampling
    2. Inscopix: up to `4x` spatial downsampling

    These values work well for several GRIN lens setups and usually do not cause a noticeable decrease in extraction quality.

??? Question "Out-of-memory (OOM) issues during CNMF extraction"
    If you encounter out-of-memory errors during CNMF extraction, even when `batch_sz` is set to `'auto'`, MATLAB may be failing to estimate available system memory correctly (this can happen on some systems).

    In these cases:

    1. Manually set `batch_sz` to a reasonable number of frames.
    2. Monitor memory usage with your operating system's system monitor.
    3. Adjust `batch_sz` up or down based on observed memory usage.

    If `'auto'` is not reliable on your system, manual configuration is recommended.

??? Question "The alignment step takes too long"
    Alignment runtime increases approximately quadratically with the number of sessions.

    1. Up to about `50` sessions is usually acceptable.
    2. Beyond that, runtime can increase dramatically.

    A common mistake is treating separate video segments from the same session as different sessions.
    This unnecessarily increases the number of sessions and can strongly impact runtime.

    Make sure split videos from the same session are not processed as independent sessions.
    See [Processing Split Data](Processing_split_data.md).

??? Question "The non-rigid motion correction module in CaliAli is deprecated. Can I use CaImAn or Suite2p for motion correction?"
    Yes, you can.

    If you use external motion-correction tools, make sure the output videos do not contain black-border artifacts.
    The CaliAli motion-correction module removes these automatically, but external workflows may leave them in place.
    Black borders can negatively affect inter-session alignment.

    After motion correction with another tool:

    1. Run the CaliAli downsampling module on the motion-corrected video.
    2. If you do not want to downsample, set the downsampling factors to `1`.
    3. The downsampling module will still convert the file to CaliAli format.
    4. You can then skip motion correction inside CaliAli.

??? Question "What if I want to change parameters in the middle of the analysis?"
    Ideally, changing parameters in the middle of the pipeline is not recommended.
    The number of possible parameter combinations is large, and not all update combinations have been fully validated.

    That said, in many cases this works without problems and can be done.

    Recommended approach:

    1. Follow [Recommended Parameter Workflow](Parameters.md#parameter-workflow) to regenerate `CaliAli_options` with the new values.
    2. If you need to update `CaliAli_options` stored in existing files, use [CaliAli_update_parameters()](Functions_doc/CaliAli_update_parameters.md#CaliAli_update_parameters).
    3. Re-run the downstream steps affected by the parameter you changed.

<a id="cnmfe-no-picker"></a>
??? Question "How do I run CNMF-E directly on aligned output without the picker?"
    Pass the aligned file path directly:

    ```matlab
    File_path = CaliAli_cnmfe(CaliAli_options.inter_session_alignment.out_aligned_sessions);
    ```

<a id="output-files"></a>
??? Question "Where are outputs saved, and what do suffixes mean?"
    Typical outputs are saved next to input files:

    1. `_ds.mat`: downsampled
    2. `_mc.mat`: motion-corrected
    3. `_det.mat`: detrended/intermediate alignment products
    4. `_Aligned.mat`: aligned/concatenated sessions

??? Question "Do I still need to visually inspect outputs?"
    Yes. Always check motion correction and alignment quality before CNMF-E extraction.
    Automated checks help, but visual quality control is still essential.

??? Question "How should I report problems?"
    Open an issue on the [CaliAli GitHub issues page](https://github.com/CaliAli-PV/CaliAli/issues) and include:

    1. MATLAB version and operating system
    2. Dataset size (dimensions, frame count, file type)
    3. Exact command used
    4. Full error message (or screenshot)
    5. Which step failed
