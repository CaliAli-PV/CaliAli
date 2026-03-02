# CaliAli Parameter Settings

The **CaliAli pipeline** uses a structured approach to **initialize, configure, and manage parameters** across different processing stages. The function [CaliAli_parameters()](Functions_doc/CaliAli_parameters.md#CaliAli_parameters) acts as the central hub for handling parameters, ensuring modularity and flexibility.

---

#### 📌 Key Features of CaliAli Parameter Management

##### 1️⃣ CaliAli submodules:
CaliAli organizes its processing pipeline into **separate submodules**, each with its own set of parameters:

- **Downsampling**
- **Preprocessing** (detrending, background processing)
- **Motion Correction** (rigid and non-rigid)
- **Inter-Session Alignment**
- **CNMF-E** (Calcium  signal extraction and demixing)

The parameters utilized by each submodule is determine on a `CaliAli_options` structure:

```matlab
◼ CaliAli_options
├─ downsampling
│  ├─ BVsize
│  │  Value: [1.5 2.25]
│  ├─ file_extension
│  │  Value: 'avi'
│  └─ ...
├─ preprocessing
│  ├─ dendrite_filter_size
│  │  Value: [0.5 0.6 0.7 0.8]
│  ├─ dendrite_theta
│  │  Value: 30
│  └─ ...
└─ ...
```

The default set of parameters can be obtained with `CaliAli_demo_parameters();` function.

---

#### Recommended Parameter Workflow <a id="parameter-workflow"></a>

The recommended way to set parameters is:

1. Edit `CaliAli_demo_parameters.m` to define or update `params`.
2. Generate the nested `CaliAli_options` structure with `CaliAli_options = CaliAli_parameters(params);`.
3. Use the generated `CaliAli_options` in each module.

This keeps parameter updates consistent across the full pipeline.

---

##### 2️⃣ Flexible Input Handling
CaliAli parameters can be set in **Three ways**:

1.    **Default Initialization:**  
       If no inputs are provided, default parameters are loaded:

       ```matlab
       CaliAli_options = CaliAli_parameters();
       ```

2.     **Custom Parameter Structure:**  
       Users can provide an existing structure to modify specific parameters:

       ```matlab
       param.sf=20 % custom sample frequency
       param.gSig=3  %custom neuron filter size
       CaliAli_options= CaliAli_parameters(param);
       ```
   
   3.     **Custom name-value pairs :**  
       Users can provide name-value pairs 

       ```matlab
       CaliAli_options = CaliAli_parameters('sf',20); % set sampling frequency to 20
       ```

The function [CaliAli_demo_parameters()](Functions_doc/CaliAli_demo_parameters.md#CaliAli_demo_parameters) demonstrates how to create this structure. The recommended approach for analyzing your own data is to modify and duplicate this code to suit your needs: `open CaliAli_demo_parameters.m`

---

#### Adjusting CaliAli Parameters.

CaliAli requires setting 33 parameters. However, in practice you only need to strictly focus on three: 

1. Frame rate: `sf`
2. Neuron filtering size: `gSig` which correspond to 1/5 of the average neuron size in pixels. If left empty, CaliAli now assigns `gSig = 5 / spatial_ds`, which matches the demo data and works well for non-downsampled videos.
3. Blood vessel size: : `BVsize` which correspond to the size of blood vessels in pixels [min, max]

Follow the Demo `Parameter_selection_demo.mlx` to learn how to define these parameters interactively using the [BV_app](Functions_doc/BV_app.md) and [NeuronSize_app](Functions_doc/NeuronSize_app.md):

```matlab 
    open Parameter_selection_demo.mlx
```

 
For advanced users, a detailed description of other parameters and methods for setting them can be found in: [Parameter Index](Parameters_index.md)



=== "Next"
Once familiarized with the `CaliAli_options` structure proceed to [Downsampling](Downsampling.md)
