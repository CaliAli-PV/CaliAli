# Inter-Session Alignment and Projection Calculation <a id="main"></a>

After [motion correction](Motion_correction.md), CaliAli calculates session projections, aligns sessions, and concatenates them for extraction.

=== "Alignment and Concatenation"
    Run:

    ```matlab
    CaliAli_align_sessions(CaliAli_options);
    ```

    !!! success "Output File"
        This step creates one `*_Aligned.mat` file plus per-session `*_det.mat` files. For naming and save-location details, see [FAQ output naming](FAQ.md#output-files).

=== "Single File Processing"
    If you do not need inter-session alignment, you can still calculate detrended projections for each file:

    ```matlab
    detrend_batch_and_calculate_projections(CaliAli_options);
    ```

    !!! success "Output File"
        This step creates `*_det.mat` files.

#### Evaluating Alignment Performance <a id="eval"></a>

While running [CaliAli_align_sessions()](Functions_doc/CaliAli_align_sessions.md#CaliAli_align_sessions), check the reported:

1. **Blood-vessel similarity score**
2. **Spatial correlation after alignment**

Quick post-alignment check:

```matlab
fprintf('BV Score: %.4f\n', CaliAli_options.inter_session_alignment.BV_score);
Alignment_metrics = CaliAli_options.inter_session_alignment.alignment_metrics
plot_alignment_scores(CaliAli_options)

P = CaliAli_options.inter_session_alignment.P;
frame = plot_P(P);
```

![BV+Neurons](files/align_demo.gif)

???+ danger "Important"
	Always visually verify alignment quality before CNMF-E. If sessions remain visibly displaced, downstream extraction quality will be affected.

For advanced details about alignment internals and stored fields, see [CaliAli_align_sessions()](Functions_doc/CaliAli_align_sessions.md#CaliAli_align_sessions).

=== "Next"
After alignment (or single-file projection processing), proceed to [Calcium Signal Extraction](extraction.md)
