function runCNMFe(in,PNR_th,Coor_th,gSig,sf)

%% clear the workspace and select data
% clear; clc; close all;

%% choose data
neuron = Sources2D();
if exist('in','var')
    nam=in;
else
    nam = [];% get_fullname('./data_1p.tif');          % this demo data is very small, here we just use it as an example
end
nam = neuron.select_data(nam);  %if nam is [], then select data interactively

%% parameters
% -------------------------    COMPUTATION    -------------------------  %
pars_envs = struct('memory_size_to_use', 256, ...   % GB, memory space you allow to use in MATLAB
    'memory_size_per_patch', 16, ...   % GB, space for loading data within one patch
    'patch_dims', [64, 64]);  % Patch dimensions

% -------------------------      SPATIAL      -------------------------  %
% pixel, gaussian width of a gaussian kernel for filtering the data. usualy 1/3 of neuron diameter
gSiz = gSig*4;          % pixel, neuron diameter
ssub = 1;           % spatial downsampling factor
with_dendrites = true;   % with dendrites or not
if with_dendrites
    % determine the search locations by dilating the current neuron shapes
    updateA_search_method = 'dilate';  
    updateA_bSiz = 5;
    updateA_dist = neuron.options.dist;
else
    % determine the search locations by selecting a round area
    updateA_search_method = 'ellipse'; %#ok<UNRCH>
    updateA_dist = 5;
    updateA_bSiz = neuron.options.dist;
end
spatial_constraints = struct('connected', false, 'circular', false);  % you can include following constraints: 'circular'
spatial_algorithm = 'hals_thresh';

% -------------------------      TEMPORAL     -------------------------  %
Fs = sf;             % frame rate
tsub = 1;           % temporal downsampling factor
deconv_flag = true;     % run deconvolution or not
deconv_options = struct('type', 'ar1', ... % model of the calcium traces. {'ar1', 'ar2'}
    'method', 'foopsi', ... % method for running deconvolution {'foopsi', 'constrained', 'thresholded'}
    'smin', -5, ...         % minimum spike size. When the value is negative, the actual threshold is abs(smin)*noise level
    'optimize_pars', true, ...  % optimize AR coefficients
    'optimize_b', true, ...% optimize the baseline);
    'max_tau', 100);    % maximum decay time (unit: frame);

nk = 1;             % detrending the slow fluctuation. usually 1 is fine (no detrending)
% when changed, try some integers smaller than total_frame/(Fs*30)
detrend_method = 'spline';  % compute the local minimum as an estimation of trend.

% -------------------------     BACKGROUND    -------------------------  %
bg_model = 'ring';  % model of the background {'ring', 'svd'(default), 'nmf'}
nb = 1;             % number of background sources for each patch (only be used in SVD and NMF model)
bg_neuron_factor = 1.5;
ring_radius = round(bg_neuron_factor * gSiz);   % when the ring model used, it is the radius of the ring used in the background model.
%otherwise, it's just the width of the overlapping area
num_neighbors = []; % number of neighbors for each neuron
bg_ssub = 2;        % downsample background for a faster speed

% -------------------------      MERGING      -------------------------  %
show_merge = false;  % if true, manually verify the merging step
merge_thr = 0.65;     % thresholds for merging neurons; [spatial overlap ratio, temporal correlation of calcium traces, spike correlation]
method_dist = 'max';   % method for computing neuron distances {'mean', 'max'}
dmin = 5;       % minimum distances between two neurons. it is used together with merge_thr
merge_thr_tempospatial = [0.8, 0.4, -inf];  % merge components with highly correlated spatial shapes (corr=0.8) and small temporal correlations (corr=0.1)

% -------------------------  INITIALIZATION   -------------------------  %
K = [];             % maximum number of neurons per patch. when K=[], take as many as possible.
min_corr = Coor_th;     % minimum local correlation for a seeding pixel
min_pnr = PNR_th;       % minimum peak-to-noise ratio for a seeding pixel
min_pixel = gSig^2;      % minimum number of nonzero pixels for each neuron
bd = 0;             % number of rows/columns to be ignored in the boundary (mainly for motion corrected data)
frame_range = [];   % when [], uses all frames
use_parallel = true;    % use parallel computation for parallel computing
center_psf = true;  % set the value as true when the background fluctuation is large (usually 1p data)
% set the value as false when the background fluctuation is small (2p)

% % -------------------------  Residual   -------------------------  %
% min_corr_res = Coor_th;
% min_pnr_res = PNR_th;
% seed_method_res = 'auto';  % method for initializing neurons from the residual

% -------------------------    UPDATE ALL    -------------------------  %
neuron.updateParams('gSig', gSig, ...       % -------- spatial --------
    'gSiz', gSiz, ...
    'ring_radius', ring_radius, ...
    'ssub', ssub, ...
    'search_method', updateA_search_method, ...
    'bSiz', updateA_bSiz, ...
    'dist', updateA_bSiz, ...
    'spatial_constraints', spatial_constraints, ...
    'spatial_algorithm', spatial_algorithm, ...
    'tsub', tsub, ...                       % -------- temporal --------
    'deconv_flag', deconv_flag, ...
    'deconv_options', deconv_options, ...
    'nk', nk, ...
    'detrend_method', detrend_method, ...
    'background_model', bg_model, ...       % -------- background --------
    'nb', nb, ...
    'ring_radius', ring_radius, ...
    'num_neighbors', num_neighbors, ...
    'bg_ssub', bg_ssub, ...
    'merge_thr', merge_thr, ...             % -------- merging ---------
    'dmin', dmin, ...
    'method_dist', method_dist, ...
    'min_corr', min_corr, ...               % ----- initialization -----
    'min_pnr', min_pnr, ...
    'min_pixel', min_pixel, ...
    'bd', bd, ...
    'center_psf', center_psf);
neuron.Fs = Fs;

%% distribute data and be ready to run source extraction
neuron.getReady(pars_envs);
evalin( 'base', 'clearvars -except parin theFiles' );
%% Load parameters stored in .mat file
[filepath,name,~] = fileparts(in);
m_data=strcat(filepath,'\',name,'.mat');
if exist(m_data, 'file')
    m=load(m_data);
    neuron.Cn=m.Cn;neuron.PNR=m.PNR;

    neuron.n_enhanced=m.opt.n_enhanced;
    neuron.CaliAli_opt=m.opt;
    if isfield(m,'Mask')
        neuron.Mask=full(m.Mask);
    else
        neuron.Mask=ones(neuron.options.d1,neuron.options.d2);
    end

    if isfield(m,'F')
        neuron.options.F=m.F;
    end
else
    get_CnPNR_from_video(gSig,{in});
    m=load(m_data);
    neuron.Cn=m.Cn;neuron.PNR=m.PNR;
    neuron.Mask=ones(neuron.options.d1,neuron.options.d2);
    neuron.n_enhanced=0;    

end
neuron.options.Cn=neuron.Cn;neuron.options.PNR=neuron.PNR;
neuron.options.Mask=neuron.Mask;
neuron.options.ind=neuron.ind;

%% adjust number of sessions for dynamic spatial

%% initialize neurons from the video data within a selected temporal range
tic
neuron =initComponents_parallel_PV(neuron,K, frame_range, 0, 1,0);
toc
% neuron.show_contours(0.8, [], neuron.Cn, 0); %
save_workspace(neuron);


%% Update components

A_temp=neuron.A;
C_temp=neuron.C_raw;
for loop=1:10
    % estimate the background components
    neuron=CNMF_CaliAli_update('Background',neuron, use_parallel);
    neuron=CNMF_CaliAli_update('Spatial',neuron, use_parallel);
    neuron=CNMF_CaliAli_update('Temporal',neuron, use_parallel);
    %% post-process the results automatically
    neuron.remove_false_positives();
    neuron.merge_neurons_dist_corr(show_merge);
    neuron.merge_high_corr(show_merge, merge_thr_tempospatial);
    neuron.merge_high_corr(show_merge, [0.9, -inf, -inf]);
    try
        dis=dissimilarity_previous(A_temp,neuron.A,C_temp,neuron.C_raw);
        dis
    catch
        weird_bug=1
    end
    A_temp=neuron.A;
    C_temp=neuron.C_raw;

    if dis<0.05
        break
    end
end    %% save the workspace for future analysis
neuron=update_residual_Cn_PNR_batch(neuron);
save_workspace(neuron);



%% Optional post-process
scale_to_noise(neuron);
neuron.C_raw=detrend_Ca_traces(neuron.Fs*2,neuron.C_raw);
justdeconv(neuron,'thresholded','ar2',0);
denoise_thresholded(neuron,3);


%% Save results
neuron.orderROIs('snr');
save_workspace(neuron);

%% show neuron contours
fclose('all');
end

%% USEFULL COMMANDS
%  fclose('all');
% justdeconv(neuron,'thresholded','ar2');

%%  To manually inspect spatial and temporal components of each neuron
%   neuron.orderROIs('sparsity_spatial');   % order neurons in different ways {'snr', 'decay_time', 'mean', 'circularity','sparsity_spatial','sparsity_temporal','pnr'}
%   neuron.viewNeurons([], neuron.C_raw);
%   neuron.viewNeurons([10,13,20], neuron.C_raw);
%% To save results in a new path run these lines a choose the new 'source_extraction' folder:

% neuron=update_folder_path(neuron);

%   cnmfe_path = neuron.save_workspace();
%% To visualize neurons contours:
%   neuron.Coor=[]
%   neuron.show_contours(0.9, [], neuron.PNR, 0);  %PNR
%   neuron.show_contours(0.6, [], neuron.Cn,0);   %CORR
%   neuron.show_contours(0.6, [], neuron.Cn.*neuron.PNR,0); %PNR*CORR


%% normalized spatial components
% A=neuron.A;A=full(A./max(A,[],1)); A=reshape(max(A,[],2),[size(neuron.Cn,1),size(neuron.Cn,2)]);
% neuron.show_contours(0.6, [], A, 0);

%% to visualize temporal traces
%   figure;strips(neuron.C_raw');
%   figure;stackedplot(neuron.C_raw');
%   view_traces(neuron);

%% Optional post-process
% neuron.merge_high_corr(1, [0.1, 0.3, -inf]);


% ix=postprocessing_app(neuron);
% neuron.viewNeurons(find(ix), neuron.C_raw);
% neuron.delete(ix);
% save_workspace(neuron);
%% update residuals
% neuron=manually_update_residuals(neuron,use_parallel);



















