# Processing Large Sessions with Automatic Chunking

CaliAli supports automatic chunking for sessions that exceed available memory. Use `batch_sz` to process long recordings in manageable frame blocks.

---

## Recommended Setup

Set `batch_sz` in your parameter file (`CaliAli_demo_parameters.m`) and then regenerate options:

```matlab
% Edit CaliAli_demo_parameters.m:
% params.batch_sz = 'auto';    % or a numeric frame count
CaliAli_options = CaliAli_demo_parameters();
```

For details on how CaliAli expects parameters to be defined and parsed, see [Recommended Parameter Workflow](Parameters.md#parameter-workflow).

`'auto'` estimates a chunk size from available memory. If needed, override with a numeric value.

Select `batch_sz` based on available system memory and video dimensions. For 512×512 pixel videos:

| System RAM | `'auto'` estimate | Manual override guidance |
|------------|-------------------|--------------------------|
| 8 GB       | ≈ 900 frames      | Stay ≤ 1000 if you see swapping |
| 16 GB      | ≈ 1700 frames     | 1500–2500 works well     |
| 32 GB      | ≈ 3300 frames     | 3000–5000 for faster runs |
| 64 GB+     | ≥ 6500 frames     | Increase gradually if monitoring memory |

Setting `batch_sz = 0` disables chunking, matching legacy behaviour. :material-information-outline:{ title="CaliAli_demo_parameters now leaves batch_sz at 'auto'. Set a numeric value if the heuristic overshoots for your hardware." }
