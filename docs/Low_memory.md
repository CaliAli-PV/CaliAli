# Processing Large Sessions with Automatic Chunking

CaliAli v1.4 introduces automatic session chunking to handle individual imaging sessions that exceed available system memory. This approach eliminates the need for manual file preparation and provides transparent processing of large datasets.

---

## Implementation

Large imaging sessions are now processed by setting the `batch_sz` parameter, which automatically divides sessions into memory-manageable chunks:

```matlab
CaliAli_options.motion_correction.batch_sz = 3000;        % Motion correction chunking
CaliAli_options.inter_session_alignment.batch_sz = 3000;  % Alignment and projection chunking
```

The chunking system operates transparently across the CaliAli pipeline:
- Motion correction maintains template consistency across chunks within each session
- Inter-session alignment preserves spatial relationships while processing chunks independently  
- Projection calculations combine chunk results appropriately
- Final outputs are identical to processing the complete session

---

## Parameter Selection

Select `batch_sz` based on available system memory and video dimensions. For 512×512 pixel videos:

| System RAM | Recommended batch_sz |
|------------|---------------------|
| 8GB        | 800-1000         |
| 16GB       | 2000-3000          |
| 32GB       | 5000-8000          |
| 64GB+      | 8000+              |

Setting `batch_sz = 0` disables chunking. :material-information-outline:{ title="This is the default when you call CaliAli_parameters() without overrides. The demo helper CaliAli_demo_parameters enables chunking by setting batch_sz = 3000 as a ready-to-use example." }

---

## Processing Workflow

Standard CaliAli processing workflow remains unchanged:

```matlab
CaliAli_options = CaliAli_demo_parameters();

% Enable chunking for large sessions
CaliAli_options.motion_correction.batch_sz = 3000;
CaliAli_options.inter_session_alignment.batch_sz = 3000;

% Standard pipeline execution
CaliAli_options = CaliAli_motion_correction(CaliAli_options);
CaliAli_options = CaliAli_align_sessions(CaliAli_options);
CaliAli_cnmfe();
```

---

## Technical Implementation

When chunking is enabled:

1. **Session Analysis**: File dimensions are analyzed to determine optimal chunk boundaries
2. **Chunk Processing**: Each chunk is processed independently while maintaining session context
3. **Result Integration**: Chunk outputs are combined into session-level results
4. **Output Generation**: Final outputs match those from complete session processing

The chunking system handles:
- Motion correction template maintenance across chunks
- Spatial alignment consistency within sessions  
- Proper projection calculation combining across temporal segments
- Memory-mapped file operations for efficient chunk writing

---

## Migration from Previous Versions

**For users of CaliAli v1.3 and earlier:**

If you previously used manual file splitting approaches (e.g., `CaliAli_divide_videos()` or manual session division), you can now:

1. Remove any manual file splitting steps from your workflow
2. Use original, unsplit session files as input
3. Add the `batch_sz` parameter to enable automatic chunking
4. Retain all other processing parameters and workflow steps

The automatic chunking system replaces previous manual approaches and provides equivalent results with simplified workflow management.

---

## Performance Considerations

**Memory Usage**: Monitor system memory during initial processing to verify chunk size selection. Reduce `batch_sz` if memory limitations occur.

**Processing Speed**: Chunk size affects processing efficiency. Very small chunks may increase overhead, while very large chunks approach memory limits.

**Consistency**: Use identical `batch_sz` values across motion correction and alignment steps for consistent processing.

---

## Troubleshooting

**Out-of-memory errors**: Reduce `batch_sz` value (try 1000-1500 frames for severely memory-limited systems)

**Slower than expected processing**: Consider increasing `batch_sz` if system memory permits

**Disable chunking**: Set `batch_sz = 0` to process entire sessions without chunking

---

## Notes

- Chunking operates at the individual session level, not across multiple sessions
- Results are computationally equivalent to processing complete sessions  
- No changes to downstream analysis workflows are required
- Compatible with all existing CaliAli processing modules
