# Welcome to CaliAli Documentation

## Introduction

- [Overview](Intro.md)
	- [About CaliAli](Intro.md#about)
	- [Key Features](Intro.md#key)

- [Usage](Usage.md)
	- [System Requirement](Usage.md#requirement)
	- [Installation](Usage.md#installation)

## Pipeline step-by-step

- [Getting Started](demo_data.md)

- [Downsampling and Motion correction](Prep.md)
	- [Downsampling](Prep.md#downsampling)
	- [Motion correction](Prep.md#mc)
	
- [Inter-session Alignment](alignment.md)
	- [Detrending and noise scaling](alignment.md#detrend)
	- [Calculation of projections](alignment.md#projections)
	- [Calculation of displacement fields](alignment.md#displacement)
	- [Evaluating aligment performance](alignment.md#evaluate)
	- [Processing single session](alignment.md#single)
	
- [Signal extraction from concatenated sessions](extraction.md)
	- [Setting PNR and Corr. Paramaters](extraction.md#cnmfapp)
	- [Initialization and CNMF](extraction.md#projections)
	- [Automatic post-processing](extraction.md#auto-post)
	- [Processing residual data (optional)](extraction.md#auto-post)
	- [Saving data and Checkpoints](extraction.md#save_data)
	
## After signal extractions
	
- [Post processing](Post.md)
	- [Monitoring extracted components](Post.md#monitor_app)
	- [Sort spatial components](Post.md#spatial_sort)
	- [Monitoring temporal components](ost.md#trace_plot)
	- [Picking neurons from residual](ost.md#residual)
	
- [Utilities](Utilities.md)
	- [Play video data in .h5 format](Utilities.md#video_app)
	- [Separate activities in sessions](Utilities.md#separate_sessions)
	- [Usefull commands](Utilities.md#commands)


Example of video embedding
<!-- Replace 'youtube_video_id' with the actual YouTube video ID -->
<iframe width="640" height="360" src="https://www.youtube.com/embed/xopvkx6CpNs" frameborder="0" allowfullscreen></iframe>