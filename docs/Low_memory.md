# CaliAli Low-Memory Processing Strategy

This page outlines the strategy for processing large calcium imaging datasets when **even a single session is too large to fit into RAM**. The approach is designed for rare but critical cases where individual sessions must be split into smaller chunks due to hardware constraints.

---

## 🧠 Why This Strategy Is Needed

CaliAli is already optimized to process data **one session at a time**, without requiring all videos to be loaded simultaneously. Even if a session consists of multiple video files, CaliAli processes them sequentially in memory.

However, in cases where **a single session** is too large to process—due to limited RAM—standard session-level processing fails. In such situations, we need to split **each individual session** into smaller parts that **can fit into RAM**.

But doing so naively would have two downsides:

1.     **Increased computation time:** CaliAli's non-rigid alignment module scales **quadratically** with the number of "sessions" it needs to process.
2.     **Potential spatial inaccuracies:** Running non-rigid alignment within segments of the *same* session may introduce small misalignments or artifacts.

---

## ✅ The Solution: Informed Session Splitting

To address these issues, we:

-     **Split each large session into smaller sub-files** (e.g., 3,000 frames per file).
-     **Instruct CaliAli** to treat all sub-files from the same original session as **belonging to the same session**, using the `same_ses_id` parameter.
-     This tells CaliAli to:
       -     Process the sub-files independently (low memory footprint)
       -     **Skip non-rigid alignment between files from the same session**
       -     Apply non-rigid alignment **only across true sessions**

---

## 📄 Reference Demo

See the accompanying live script for a full implementation:

➡️ `LowMemory_CaliAli_Demo.mlx`

This demo simulates multi-session calcium imaging data and applies the low-memory strategy, illustrating how to split sessions, apply session continuity, and run the pipeline efficiently.

## ⚙️ Implementation

1. **Split large session files** (if needed):

   ```matlab
   max_frame = 3000;
   ses_id = CaliAli_divide_videos(max_frame);
   ```

   This saves split files as `_b1`, `_b2`, etc., and returns the correct session mapping.

2. **Set session continuity explicitly**:

   ```matlab
   CaliAli_options.inter_session_alignment.same_ses_id = ses_id;
   ```

3. **Continue with the standard CaliAli pipeline**:

   ```matlab
   CaliAli_options = CaliAli_downsample(CaliAli_options);
   CaliAli_options = CaliAli_align_sessions(CaliAli_options);
   File_path = CaliAli_cnmfe();
   ```
---



