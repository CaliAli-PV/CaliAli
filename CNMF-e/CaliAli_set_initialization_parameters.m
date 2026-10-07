function CaliAli_set_initialization_parameters(varargin)
%% CaliAli_set_initialization_parameters: Set initialization parameters for CNMF-E processing.
%
% Opens the app where the PNR and correlation thresholds, gSig and the seed mask
% are chosen for each file. Press Load Data in the app to choose the _det or
% _Aligned .mat files; Done saves the values to each file.
%
% Inputs:
%   None. An input given by older scripts (CaliAli_options) is accepted and
%   ignored: the app reads the settings from the files it loads.
%
% Outputs:
%   None (the settings are saved in the CaliAli_options of each file).
%
% Usage:
%   CaliAli_set_initialization_parameters();
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025
CNMFe_app;
