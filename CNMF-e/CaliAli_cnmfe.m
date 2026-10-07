function file_path = CaliAli_cnmfe(input_files)
%% CaliAli_cnmfe: Runs CNMF-E for source extraction.
%
% Inputs:
%   input_files - (Optional) Path, or cell array of paths, of the .mat files to
%                 process (typically "*_Aligned.mat" or "*_det.mat"). If omitted,
%                 the user is prompted to select them.
%
% Outputs:
%   file_path - Cell array with one entry per input file: the path of the .mat
%               file where the extracted components (neuron) were saved.
%
% Usage:
%   CaliAli_cnmfe();
%   file_path = CaliAli_cnmfe(CaliAli_options.inter_session_alignment.out_aligned_sessions);
%
% Description:
%   - Prompts the user to select input files for processing.
%   - Calls `runCNMFe` on each selected file, which loads the `CaliAli_options`
%     structure stored in it.
%   - Iterates through all selected files and processes them sequentially.
%   - Catches and logs errors if any file fails to process.
%   - Saves the processed results, including spatial and temporal components.
%
% Features:
%   - Iterative CNMF-E optimization with stopping criteria.
%   - Adaptive merging of highly correlated components.
%   - Integration with CaliAli preprocessing for residual refinement.
%   - Error handling for failed files, preventing disruption of batch processing.
%
% Notes:
%   - The function uses helper functions including:
%     - `runCNMFe`
%     - `CaliAli_load` (to load preprocessing parameters)
%   - For manual classification of components, use `postprocessing_app(neuron, 0.6)`.
%   - To visualize extracted traces, use `view_traces(neuron)`.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

if ~exist('input_files','var') || isempty(input_files)
input_files = uipickfiles('FilterSpec', '*.mat', 'REFilter', '_Aligned*\.mat$|_det*\.mat$');
end

cn_tic= tic;
if isstring(input_files) || ischar(input_files)
   input_files={input_files};
end
file_path=cell(numel(input_files),1);
for i=1:numel(input_files)
    try
        temp=input_files{i};
        file_path{i}=runCNMFe(temp);
    catch ME
        m=input_files{i};
        fprintf(['fail to process ',m,'\n'])
        rethrow(ME)
    end
    clearvars -except file_path i input_files cn_tic
end

cprintf('*blue','Processing completed in %.2f minutes.\n', toc(cn_tic)/60);
end