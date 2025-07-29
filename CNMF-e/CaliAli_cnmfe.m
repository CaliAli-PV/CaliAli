function file_path = CaliAli_cnmfe()
%% CaliAli_cnmfe: Runs CNMF-E for source extraction in neuron or dendrite imaging data.
%
% Inputs:
%   This function prompts the user to select .mat files containing the imaging data 
%   and CNMF-E parameters. The selected files should follow the naming pattern "*_ds*.mat".
%
% Outputs:
%   This function does not return an output but processes each selected file 
%   and saves the extracted neuron or dendrite components to the workspace.
%
% Usage:
%   CaliAli_cnmfe();
%
% Description:
%   - Prompts the user to select input files for processing.
%   - Loads the `CaliAli_options` structure from each selected file.
%   - Determines whether the dataset corresponds to neuron or dendrite imaging.
%   - Calls `runCNMFe` for neuron data or `runCNMFe_dendrite` for dendrite data.
%   - Iterates through all selected files and processes them sequentially.
%   - Catches and logs errors if any file fails to process.
%   - Saves the processed results, including spatial and temporal components.
%
% Features:
%   - Automatic selection of CNMF-E pipeline based on imaging structure.
%   - Iterative CNMF-E optimization with stopping criteria.
%   - Adaptive merging of highly correlated components.
%   - Integration with CaliAli preprocessing for residual refinement.
%   - Error handling for failed files, preventing disruption of batch processing.
%
% Notes:
%   - The function uses helper functions including:
%     - `runCNMFe` (for neuron imaging)
%     - `runCNMFe_dendrite` (for dendrite imaging)
%     - `CaliAli_load` (to load preprocessing parameters)
%   - For manual classification of components, use `postprocessing_app(neuron, 0.6)`.
%   - To visualize extracted traces, use `view_traces(neuron)`.
%
% Author: Pablo Vergara  
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025

input_files = uipickfiles('FilterSpec', '*.mat', 'REFilter', '_Aligned*\.mat$|_det*\.mat$');

file_path=cell(size(input_files,1),1);
for i=1:size(input_files,1)
    try
        temp=input_files{i};
        CaliAli_options=CaliAli_load(temp,'CaliAli_options');
        if strcmp(CaliAli_options.preprocessing.structure,'neuron')
            file_path{i}=runCNMFe(temp);
        elseif strcmp(CaliAli_options.preprocessing.structure,'dendrite')
            file_path{i}=runCNMFe_dendrite(temp);
        end
    catch ME
        m=input_files{i};
        fprintf(['fail to process ',m,'\n'])
        rethrow(ME)
    end
    clearvars -except file_path i input_files
end