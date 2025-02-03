# Welcome to CaliAli Documentation
test
## Introduction

- [About CaliAli](Intro.md)
	- [Key Features](Intro.md#key)
	- [Version History](Intro.md#vh)
	- [License](Intro.md#li)
	- [Questions about CaliAli?](Intro.md#q)

- [Installation and system requirements](Usage.md)
	- [System Requirement](Usage.md#requirement)
		- [Hardware](Usage.md#hardware)
		- [Others](Usage.md#other)
	- [Installation](Usage.md#installation)

## Pipeline step-by-step

!!! note
	Already familiar with the documentation? Get a quick overview of the functions you need to run in the [TL;DR](TLDR.md) section.

- [Getting Started](demo_data.md)
	- [CaliAli processing steps](demo_data.md#ps)

- [Downsampling and Motion Correction](Prep.md)
	- [Downsampling and Conversion to .h5 Format](Prep.md#downsampling)
	- [Motion Correction](Prep.md#mc)

	
- [Inter-Session Alignment](alignment.md#main)
	- [Evaluate Alignment Performance](alignment.md#eval)
	- [Processing Sessions without Concatenation](alignment.md#single)
	
- [Calcium Signal Extraction with CaliAli](extraction.md)
	- [Select Extraction Parameters](extraction.md#gui)
	- [Adjusting PNR and Corr. Thresholds](extraction.md#adjust_pnr)
	- [Extracting Calcium Signals](extraction.md#ecs)
		
- [Post-processing](Post.md)
	- [Monitoring Extracted Components](Post.md#monitor_app)
	- [Sort spatial Components](Post.md#spatial_sort)
	- [Deleting and Merging Components](Post.md#del_merge)
	- [Picking Neurons from Residual](Post.md#residual)
	
## Others
	
- [Utilities](Utilities.md)
	- [Reproducing Video Data in .h5 Format](Utilities.md#h5video)
	- [Monitoring Extracted Calcium Transients](Utilities.md#mt)
	- [Separate Data from Different Sessions](Utilities.md#separate)
	- [Other Functions](Utilities.md#of)
	
- [TL;DR](TLDR.md)



<!--Example of video embedding-->
<!-- Replace 'youtube_video_id' with the actual YouTube video ID -->
<!--<iframe width="640" height="360" src="https://www.youtube.com/embed/xopvkx6CpNs" frameborder="0" allowfullscreen></iframe>-->