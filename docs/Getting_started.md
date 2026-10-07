# Getting Started

This guide walks through the CaliAli pipeline with the demo script, but the same workflow applies to your own data.

#### Installation

First follow the CaliAli installation notes [Installation and System Requirements](Installation.md)

	
#### CaliAli Processing Steps Overview <a id="ps"></a>

This guide is based on `Demo_pipeline.m`. The demo first downloads a calcium-imaging video simulator (this needs an internet connection) and uses it to generate four simulated sessions, which it then processes step by step. In MATLAB, run:

```matlab
open Demo_pipeline.m
```

??? Info "How long it takes to process the Demo data?"
	Processing the demo data is expected to take approximately 5 minutes on a standard desktop computer.

CaliAli runs in five steps:

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

<a id="no-gui-workflow"></a>
??? Question "Can I automate this process without manually selecting files?"
	Yes. If you pass file lists through `CaliAli_options`, you can run the pipeline without file-selection popups:

	```matlab
	CaliAli_options = CaliAli_demo_parameters();
	CaliAli_options.downsampling.input_files = {'C:\data\session_1.avi', 'C:\data\session_2.avi'};   % your videos or session folders
	CaliAli_options = CaliAli_downsample(CaliAli_options);
	CaliAli_options.motion_correction.input_files = CaliAli_options.downsampling.output_files;
	CaliAli_options = CaliAli_motion_correction(CaliAli_options);
	CaliAli_options.inter_session_alignment.input_files = CaliAli_options.motion_correction.output_files;
	CaliAli_options = CaliAli_align_sessions(CaliAli_options);
	File_path = CaliAli_cnmfe(CaliAli_options.inter_session_alignment.out_aligned_sessions);
	```

=== "We will now navigate into each of the main steps in the CaliAli pipeline"
Proceed to [Setting CaliAli Parameters](Parameters.md)
