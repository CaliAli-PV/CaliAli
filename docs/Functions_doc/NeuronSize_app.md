### NeuronSize_app {#NeuronSize_app}

#### Description
Interactive graphical interface to estimate the optimal neuron size for inter-session alignment and initialization in CNMF-E processing within the CaliAli pipeline. This tool processes a single representative frame to generate neuron-enhanced images across a range of filter sizes, allowing manual selection of the most appropriate size.

##### Function Inputs:
| Parameter Name | Type     | Description                                                                 |
|----------------|----------|-----------------------------------------------------------------------------|
| lim            | Vector   | (Optional) Range of neuron filter radii to evaluate, in pixels. Default: `1:0.5:5` |

##### Function Outputs:
| Output Name | Type     | Description                                                 |
|-------------|----------|-------------------------------------------------------------|
| r           | Scalar   | Selected neuron size (Gaussian filter sigma) in pixels      |

##### Example usage:
```matlab
r = NeuronSize_app();          % Use default neuron size range
r = NeuronSize_app(1:0.5:10);   % Custom size range
```

!!! Info "The selected frame is chosen to highlight neuron contrast."
    - If the file name contains `_mc`, the maximum projection across time is used.  
    - Otherwise, the frame with the global maximum intensity is selected.  
    The goal is to highlight neuron bodies clearly across size scales.

#### Neuron Size Selection Interface

The app opens a window showing neuron-enhanced images computed using various filter sizes (`gSig`).  
In the interface:
- Use the **slider** to select the size at which neurons appear best defined.
- The images update interactively to reflect the enhancement level at each size.

Once satisfied, press `Ok!` to confirm your selection.  
The chosen value will be printed in the MATLAB console:

```matlab
The chosen Neuron size is [2.50]
```

##### Internally, the function performs the following:
- Loads the video using `CaliAli_load`.
- Chooses a representative frame based on motion correction status.
- Applies **border removal** using `remove_borders`.
- Enhances neuron visibility across sizes using `neuron_stack`.
- Displays the results in a GUI using `NeuronSize_app_in` for manual selection.
