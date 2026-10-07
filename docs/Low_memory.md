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

`batch_sz` accepts:

| Value | What it does |
|-------|--------------|
| `'auto'` (default) | Picks a chunk size from your memory and frame size, and never asks for more memory than is currently free. |
| a number, e.g. `1000` | Number of frames per chunk. |
| `'all_frames'` | No chunking: each step loads the whole recording at once. |
| `'per_session'` | One chunk per session, so no chunk spans two sessions. |

`batch_sz = 0` from older scripts still works as before.

During neuron extraction, a chunk never spans two sessions, with any setting except `'all_frames'`: each session is split into equal chunks, and a session shorter than the chunk size is one chunk. Sessions recorded on different days can differ in brightness, and a chunk holding parts of two such sessions loses most of its neurons. If you switch off detrending and neuron enhancement, avoid `'all_frames'` for the same reason.

For 512×512 pixel videos, `'auto'` picks about:

| System RAM | `'auto'` (frames) |
|------------|-------------------|
| 8 GB       | ≈ 600             |
| 16 GB      | ≈ 1200            |
| 32 GB      | ≈ 2400            |
| 64 GB+     | ≥ 4800            |

These are upper limits: `'auto'` picks the largest safe size, and fewer frames when part of the memory is already in use, for example by other programs. Set a smaller number only if MATLAB runs out of memory. During extraction, CaliAli also starts fewer parallel workers when memory is short, and tells you why.
