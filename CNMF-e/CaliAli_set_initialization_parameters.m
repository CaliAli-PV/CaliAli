function CaliAli_set_initialization_parameters(CaliAli_options)
%% CaliAli_set_initialization_parameters: Set initialization parameters for CNMF-E processing.
%
% Inputs:
%   CaliAli_options - Structure containing preprocessing settings.
%                     Details can be found in CaliAli_demo_parameters().
%
% Outputs:
%   None (initializes CNMF-E application based on structure type).
%
% Usage:
%   CaliAli_set_initialization_parameters(CaliAli_options);
%
% Notes:
%   - Calls `CNMFe_app_dendrite` if processing dendrites (in progress).
%   - Calls `CNMFe_app` for neuron-based processing.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025
CNMFe_app;
