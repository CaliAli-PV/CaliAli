<p align="center">
  <img src="./Demo/main_panel.png" alt="slider" width="800px"/>
</p>

# MIN1PIPE (reads "minipipe")
[CaliAli, a tool for long-term tracking of neuronal population dynamics in calcium imaging](https://www.biorxiv.org/content/10.1101/2023.05.19.540935v1). 

CaliAli is a software tool for tracking neuronal population dynamics in calcium imaging over long periods. It utilizes blood vessel information to improve inter-session alignment and maximize the number of trackable neurons. By incorporating an alignment-before-extraction strategy, it enhances thedetectability of weak signals and excels in scenarios involving neural remapping and high spatial overlap.

## Contents
1. [Features](#Features)
2. [System requirments](#System-requirments)
3. [Installation](#Installation)
4. [Usage and Demo](#dataset)
6. [Potential Troubles](#Potential_Troubles)
8. [References](#references)

---

## Features
CaliAli includes the following modules:
- **`Downsampling Videos`**: Provides functions to downsample videos, specifically for Inscopix videos (.ISXD) and AVI videos obtained with UCLA miniscope.
- **`Motion Correction`**: Corrects movement in the field of view using information from blood vessels.
- **`Alignment of Sessions`**: Aligns multiple calcium imaging sessions by utilizing blood vessel projections obtained from motion-corrected calcium imaging videos.
- **`Neural Signal Extraction`**: Offers a graphical user interface (GUI) to estimate optimal neural extraction parameters and customize the CNMF-E pipeline for extracting calcium signals from long, concatenated video sequences.
- **`Post-processing and Evaluation`**: Provides a GUI for easy labeling and identification of false positives.
- **`Manual Extraction of Missed Neurons`**: Offers a GUI where residual images are examined, and users can choose new seed pixels to re-execute the extraction process.
- **`Additional Visualization Commands`**: Includes additional commands for visualization purposes.

## System requirments

CaliAli runs in MATLAB and requires the following toolbox:
**Additional Matlab toolboxes**:
- 'Signal Processing Toolbox'
- 'Image Processing Toolbox'
- 'Statistics and Machine Learning Toolbox'
- 'Parallel Computing Toolbox'

Others:
- To downsample inscopix data, the Inscopix Data Processing software is required.
**Versions CaliAli has been tested on**:

CaliAli has been tested on Windows 11, and no anticipated problems are expected with other operating systems.
MATLAB 2022a and 2023a.

## Installation
- Download/clone the git repository of the codes
- Add to the MATLAB path.

## Usage and Demo

Instructions for running CaliAli can be found in the "Tutorial.docx" file located in the Demo folder. This document provides guidance on running each module using your own data or the demo files included in the repository. Details about the expected outputs of each module and their estimated running times are also included in the tutorial. For reproducing the quantitative data and accessing the calcium imaging videos used in the CaliAli manuscript,please refer to the Mendeley repository mentioned in the manuscript.

**Using CaliAli to process individual sessions**:
If you prefer to process individual files without tracking across multiple sessions using CaliAli, you can execute the "detrend_Batch(sf, gSig, neuron_enhance)" function instead of "align_sessions_PV". This will specifically perform detrending and background subtraction, as well as compute the required projection for further analysis. See the demo tutorial for more details.


## Potential Troubles

- CaliAli enhances dark elongated structures in the field of view to extract blood vessels. However, if the field of view is contaminated with blood clots or other obstructing particles, CaliAli may yield poor results.
- It's important to note that CaliAli, as well as any other tracking algorithm, cannot correct displacement in the z-axis. When recording new calcium imaging sessions, ensure that the focal plane matches the previous sessions. Making small adjustments to the focal plane can significantly improve neural trackability. You can estimate the optimal focus by monitoring both the previously recorded sessions and the current one.
- Please note that CaliAli is not compatible with motion correction algorithms that utilize patches to correct non-rigid displacement, such as NoRMCorre. These algorithms introduce vertical and horizontal artifacts at the concatenation point between patches, which can contaminate the blood vessel projection. It is recommended to use the motion correction algorithm provided in CaliAli or the non-rigid motion correction algorithm of MIN1PIPE.

## References

Please cite CALIALI(https://www.biorxiv.org/content/10.1101/2023.05.19.540935v1) if it helps your research.

Vergara, Pablo, Yuteng Wang, Sakthivel Srinivasan, Yoan Cherasse, Toshie Naoi, Yuki Sugaya, Takeshi Sakurai, Masanobu Kano, and Masanori Sakaguchi. "The CaliAli tool for long-term tracking of neuronal population dynamics in calcium imaging." bioRxiv (2023): 2023-05.


