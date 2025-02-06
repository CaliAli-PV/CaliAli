#CaliAli parameter settings

The **CaliAli pipeline** uses a structured approach to **initialize, configure, and manage parameters** across different processing stages. The function [CaliAli_parameters()](Functions_doc/CaliAli_parameters.md#CaliAli_parameters) acts as the central hub for handling parameters, ensuring modularity and flexibility.

---

#### 📌 Key Features of CaliAli Parameter Management

##### 1️⃣ Modular Parameter Handling
CaliAli organizes its processing pipeline into **separate submodules**, each with its own set of parameters:

- **Downsampling**
- **Preprocessing** (detrending, background processing)
- **Motion Correction** (rigid and non-rigid)
- **Inter-Session Alignment**
- **CNMF-E** (Calcium  signal extraction and demixing)

---

##### 2️⃣ Flexible Input Handling
CaliAli parameters can be set in **two ways**:

1. **Default Initialization:**  
   If no inputs are provided, default parameters are loaded:

   ```matlab
   opt = CaliAli_parameters();
   ```

2. **Custom Parameter Structure:**  
   Users can provide an existing structure to modify specific parameters:

   ```matlab
   opt = CaliAli_parameters(existing_opt);
   ```

The function [CaliAli_demo_parameters()](Functions_doc/CaliAli_demo_parameters.md#CaliAli_demo_parameters) demonstrates how to create this structure. The recommended approach for analyzing your own data is to modify and duplicate this code to suit your needs: `open(CaliAli_demo_parameters());`

---

#### Adjusting CaliAli Parameters.

CaliAli requires setting 33 parameters. However, in practice you only need to strictly focus on three: 

1. Frame rate: `sf`
2. Neuron filtering size: `gSig` which correspond to 1/5 of the average neuron size in pixels.
3. System Memory:

| Parameter Name           | Default Value | Description | How to Choose |
|--------------------------|--------------|-------------|--------------|
| `memory_size_to_use`     | `total_system_memory_GB` | Total available memory for computation | Adjust based on available RAM. |
| `memory_size_per_patch`  | `16`       | Memory allocated per patch | Adjust based on available RAM and number of patches. |
 
For advanced users, a detailed description of other parameters and methods for setting them can be found in: [Parameter Index](Parameters_index.md)

When you run `CaliAli_options=CaliAli_demo_parameters();` you will get a structure as follow:
 
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


=== "Next"
Once familiarized with the `CaliAli_options` structure proceed to [Downsampling](Downsampling.md)