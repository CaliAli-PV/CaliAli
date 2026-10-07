### manually_classify_spatial_fun {#manually_classify_spatial_fun}

```matlab
function ix=manually_classify_spatial_fun(neuron,ix)
```

#### Description
This MATLAB function opens a window to manually classify neurons by their spatial footprints. Footprints in the left panel are labeled `true` and footprints in the right panel `false`. Click footprints to mark them, use `>>` / `<<` to move the marked ones to the other panel, and press `Done!` to finish.

##### Function Inputs:
| Parameter Name | Type   | Description                       |
|---------------|--------|-----------------------------------|
| neuron        | struct | A structure containing neuron data.|
| ix            | logical array | (Optional) Starting classification, one entry per component (`true` = left panel). Default: all `true`.|

##### Function Outputs:
| Parameter Name | Type    | Description                 |
|---------------|---------|-----------------------------|
| ix            | logical array | Classification after user interaction, one entry per component in the order of `neuron.A` (`true` = left panel, `false` = right panel).|

##### Example usage:
```matlab
ix = manually_classify_spatial_fun(neuron);
neuron.delete(~ix);   % delete the components moved to the right panel
```
