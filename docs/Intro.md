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


## Version History <a id="vh"></a> 

### CaliAli 1.0.1 Release Notes
**April 22nd 2024**

- Introduced a new app for determining optimal blood vessel (BV) size.
- Removed unnecessary or deprecated functions.
- Several improvements to the documentation.

[Full Changelog](https://github.com/CaliAli-PV/CaliAli/compare/v1.0...v1.0.1) on GitHub.

### CaliAli Stable Version 1.0 Release Notes
**April 19th 2024**

We are excited to announce the first stable version of CaliAli, featuring significant enhancements and improvements. Below are the key changes in this release:

***Changes***:

- **Full Online Documentation:** Access comprehensive documentation to guide you through using CaliAli efficiently.

- **Optimized Computational Performance:** CaliAli is now optimized for low memory requirements, ensuring smoother and more efficient processing.

- **Improved Session Analysis:** Analyze individual sessions and perform multisession concatenation seamlessly.

- **Enhanced Blood Vessel (BV) Extraction:** Minimized vignetting artifacts for improved accuracy in BV extraction.

- **New BV Stability Metric:** Evaluate tracking performance with a new stability metric integrated into BV extraction.

- **Bug Fixes in GUIs:** Addressed several bugs in the graphical user interfaces (GUIs) for improved usability.

- **Enhanced Inter-Session Alignment:** Further improvements to the inter-session alignment module for precise video session alignment.

[Full Changelog](https://github.com/CaliAli-PV/CaliAli/compare/Biorxiv-Version...main) on GitHub.

---

### CaliAli Beta Release 1.0-beta 
**May 19th 2023**

The first beta release of CaliAli is now available, offering advanced capabilities for extracting neural signals from one-photon calcium imaging data in free-moving conditions.

For details, refer to the [BioRxiv preprint](https://www.biorxiv.org/content/10.1101/2023.05.19.540935v1).

Explore CaliAli to analyze calcium imaging data with accuracy and efficiency, shaping the future of neural signal extraction in neuroscience research.



## GNU General Public License v3.0 <a id="li"></a>

!!! abstract "CaliAli License"

	:fontawesome-solid-scale-balanced: CaliAli-PV/CaliAli is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html).
	
	Permissions of this strong copyleft license are conditioned on making available complete source code of licensed works and modifications, which include larger works using a licensed work, under the same license. Copyright and license notices must be preserved. Contributors provide an express grant of patent rights

	-	**Permissions** :white_check_mark: (1)
		{ .annotate }
		
		1. - **Commercial use** :white_check_mark:
			- **Modification** :white_check_mark:
			- **Distribution** :white_check_mark:
			- **Patent use** :white_check_mark:
			- **Private use** :white_check_mark:
	
	-	**Limitations** :x:	(1)
		{ .annotate }
		
		1.	- **Liability** :x:
			- **Warranty** :x:
		
	-	**Conditions** :exclamation:(1)
		{ .annotate }
		
		1.  - **License and copyright notice:** Must be preserved
			- **State changes:** Must disclose changes made
			- **Disclose source:** Source code must be made available
			- **Same license:** Modifications must be licensed under the same terms

## Questions about CaliAli? <a id="q"></a>

We're currently developing a comprehensive Frequently Asked Questions (FAQ) section for CaliAli, coming soon! In the meantime, please don't hesitate to reach out on our [discussion board](https://github.com/CaliAli-PV/CaliAli/issues) if you have any questions or need assistance.


=== "Next"
Proceed to [Installation and system requirements](Usage.md)