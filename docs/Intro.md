CaliAli is a comprehensive suite designed for extracting neural signals from one-photon calcium imaging data collected across multiple sessions in free-moving conditions. CaliAli incorporates all the necessary modules to extract long-term tracked calcium signals from raw video sessions.

![CaliAli Pipeline](files/pipeline_summary.png)

## Key Features <a id="key"></a>

CaliAli includes the following functions:


-	Downsampling Videos: Provides functions for downsampling videos.
-	Motion Correction: Corrects rigid and non-rigid motion artifacts within the field of view.
-	Automatic Detrending and Preprocessing: CaliAli automatically preprocesses sessions to prepare them for concatenation in subsequent steps.
-	Alignment of Sessions: Aligns multiple calcium imaging sessions using blood vessel projections obtained from motion-corrected calcium imaging videos.
-	Neural Signal Extraction: Offers a graphical user interface (GUI) to estimate optimal neural extraction parameters and customize the CNMF-E pipeline for extracting calcium signals from long, concatenated video sequences.
-	Post-processing and Evaluation: Provides a GUI for easy labeling and identification of false positives.
-	Manual Extraction of Missed Neurons: Offers a GUI for examining residual images and allowing users to choose new seed pixels to re-execute the extraction process.
-	Several other functions that facilitate video monitoring and calcium signal tracking throughout the extraction process.

=== "Next"
Proceed to [Installation and system requirements](Usage.md)