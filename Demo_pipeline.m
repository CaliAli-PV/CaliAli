
% Load the demo parameters. Modifiy this function to analyze your own data.
params=CaliAli_demo_parameters();
% params=CaliAli_demo_parameters_dendrites_1p();

% Do downsampling:
CaliAli_options=CaliAli_downsample(params);  

CaliAli_options.motion_correction.input_files=CaliAli_options.downsampling.output_files;

CaliAli_options=CaliAli_motion_correction(CaliAli_options);


CaliAli_options.inter_session_alignment.input_files=CaliAli_options.motion_correction.output_files;


CaliAli_align_sessions(CaliAli_options);


opt=detrend_batch_and_calculate_projections(CaliAli_options);


opt=detrend_batch_and_calculate_projections(CaliAli_parameters(params));