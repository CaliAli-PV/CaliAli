#### I. Processing Video Sessions Split Into Multiple Files

It is common for continuous calcium imaging data to be saved across multiple video files for easier access. For example as follows:

```matlab
◼ My_data
├─ Session_1_day_0
│  ├─ 0.avi
│  ├─ 1.avi
│  ├─ ...
│  └─ 12.avi
├─ Session_2_day_5
│  ├─ 0.avi
│  ├─ 1.avi
│  ├─ ...
│  └─ 14.avi
└─ Session_3_day_15
   ├─ 0.avi
   ├─ 1.avi
   ├─ ...
   └─ 14.avi
```

Treating each of these split videos as independent sessions is not ideal, as using the inter-session alignment pipeline is more computationally demanding than simply aligning and motion-correcting the concatenated chunk.

The recommended approach is to select the parent folder when calling:
```matlab
CaliAli_options = CaliAli_downsample(CaliAli_options);
```

This will generate three `.mat` files—one for each session—containing the data from all individual segments concatenated. By default, CaliAli searches for `.avi` files and concatenates them using [natural sorting](https://en.wikipedia.org/wiki/Natural_sort_order) based on their filenames. The output will look like:

```matlab
◼ My_data
├─ Session_1_day_0
├─ Session_2_day_5
├─ Session_3_day_15
├─ Session_1_day_0_con.mat
├─ Session_1_day_5_con.mat
└─ Session_3_day_15_con.mat
```

![video_app](../files/split_files.gif)


??? Question "What about video sessions split into multiple TIFF files?" 
       You can set the CaliAli parameter `CaliAli_options.downsampling.file_extension = 'tiff'`. 
	   
	   The simplest way is to modify the demo options:
	   
	  ```matlab
	   edit CaliAli_demo_parameters
	  ```
      and set `params.file_extension = 'tiff';`. This will tell CaliAli to search for tiff files. 