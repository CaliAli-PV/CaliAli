% Load the demo parameters. 
CaliAli_options=CaliAli_demo_parameters(); % <-- Modifiy this function to analyze your own data.

% Do downsampling:
CaliAli_options=CaliAli_downsample(CaliAli_options);  
% Do motion correction
CaliAli_options=CaliAli_motion_correction(CaliAli_options);

% Align sessions
CaliAli_align_sessions(CaliAli_options);
% If only one file
% opt=detrend_batch_and_calculate_projections(CaliAli_options);

% Estiamte CNMFe initialization parameters
CNMFe_app

%Run CNMF-E
CaliAli_cnmfe()



%% Optional post-process
%Manually abel component with post-processing app:
% ix=postprocessing_app(neuron,0.6);

% Review labeled components:
% neuron.viewNeurons(find(ix), neuron.C_raw);
% Or delete them:
% neuron.delete(ix);

%Manually merge neuron with less conservative parameters
% neuron.merge_high_corr(1, [0.3, 0.2, -inf]);

% Save the neuron data:
% save_workspace(neuron);
 
%% update residuals
% neuron=manually_update_residuals(neuron,use_parallel);

%% USEFULL COMMANDS
%% to visualize temporal traces
%   view_traces(neuron);

%%  To manually inspect spatial and temporal components of each neuron
%   neuron.orderROIs('sparsity_spatial');   % order neurons in different ways {'snr', 'decay_time', 'mean', 'circularity','sparsity_spatial','sparsity_temporal','pnr'}
%   neuron.viewNeurons([], neuron.C_raw);
%   neuron.viewNeurons([10,13,20], neuron.C_raw);

%% To save results in a new path run these lines a choose the new 'source_extraction' folder:
%   neuron=update_folder_path(neuron);
%   cnmfe_path = neuron.save_workspace();






