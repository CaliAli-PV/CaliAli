# Getting Started

This guide explains how to run each module using four demo video sessions from CaliAli/Demos, but the steps apply to your own data. The demo videos are pre-motion-corrected. Expected outputs and estimated runtimes are also covered.

#### Installation

First follow the CaliAli installation notes [Installation and System Requirements](Installation.md)

	
#### CaliAli Processing Steps Overview <a id="ps"></a>

This guide is based on `Demo_pipeline.mlx`. Execute in the MATLAB command window `open Demo_pipeline.mlx` to explore the script. The refreshed demo now synthesises full-resolution videos using the [Simulate_Ca_Imaging_video](https://github.com/vergaloy/Simulate_Ca_Imaging_video) toolkit, shows how spatial downsampling preserves salient features, and injects motion artefacts so you can watch the motion-correction module recover a stable field of view.

!!! tip "Generate your own synthetic datasets"
	The simulator lets you control the field of view, neuron count, firing rates, motion trajectories, noise profile, and session length. By exporting different configurations you can stress-test CaliAli under varied memory budgets (frame size × frame count), experiment with chunk sizes (`batch_sz`), or benchmark extraction quality as you scale neuron density. See the repository README for detailed parameter examples.

??? Info "How long it takes to process the Demo data?"
	Processing the demo data is expected to take approximately 5 minutes on a standard desktop computer. This includes the steps bellow:

In principle CaliAli operate in 5 steps:

1. [Setting CaliAli Parameters](Parameters.md)

2. [Downsampling and File Conversion](Downsampling.md)

3. [Motion Correction](Motion_correction.md)

4. [Inter-session Alignment](alignment.md)

5. [Signal Extraction From Concatenated Sessions](extraction.md)

##### Workflow:

``` mermaid
sequenceDiagram
    participant U as User
    participant DS as CaliAli_downsample()
    participant MC as CaliAli_motion_correction()
    participant AT as CaliAli_align_sessions()
    participant CN as CaliAli_cnmfe()
    participant PP as Postprocessing

    U->>DS: Select input video(s)
    DS->>U: Downsampled .mat files output
    U->>MC: Provide downsampled files for motion correction
    MC->>U: Motion corrected video saved
    U->>AT: Initiate inter-session alignment
    AT->>U: Updated transformation parameters
    U->>CN: Run CNMF‐e extraction on aligned videos
    CN->>U: Neuronal components extracted and saved
    U->>PP: Launch postprocessing for residual updates and manual review
    PP->>U: Updated neuron data ready for further analysis
``` 
<small>*Schematic of the CaliAli pipeline for neuronal imaging analysis. The user (U) supplies raw videos to the downsampling module (DS), which are then motion-corrected (MC) and aligned (AT). CNMF-e extraction (CN) identifies neuronal components, and postprocessing (PP) refines and reviews these outputs. Arrows denote the flow of data and user interactions.*</small>

In principle, the entire CaliAli pipeline can be run on the demo data using just the following lines of code:

```matlab
% Define CaliAli Parameters 
CaliAli_options=CaliAli_demo_parameters(); % <-- Modify this function to analyze your own data.
% Do downsampling:
CaliAli_options=CaliAli_downsample(CaliAli_options);  
% Do motion correction
CaliAli_options=CaliAli_motion_correction(CaliAli_options);
% Do Inter-session Alignment
CaliAli_align_sessions(CaliAli_options);
%Run Signal extraction from concatenated sessions
CaliAli_cnmfe()
```

=== "We will now navigate into each of the main steps in the CaliAli pipeline"
Proceed to [Setting CaliAli Parameters](Parameters.md)
