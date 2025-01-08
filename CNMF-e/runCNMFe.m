function runCNMFe(in)

neuron = Sources2D();
pars=CaliAli_load(in,'CaliAli_options.cnmf');
neuron = fill_neuron(neuron, pars);
neuron.options = fill_neuron(neuron.options, pars);
neuron.CaliAli_options=CaliAli_load(in,'CaliAli_options');
neuron.select_data(in);
neuron.getReady();
evalin( 'base', 'clearvars -except parin theFiles' );
%% Load parameters stored in .mat file

%% initialize neurons from the video data
tic
neuron =initComponents_parallel_PV(neuron,[],[], 0, 1,0);
toc
% neuron.show_contours(0.8, [], neuron.Cn, 0); %
Initialization=neuron;
CaliAli_save(in(:),Initialization);


%% Update components

A_temp=neuron.A;
C_temp=neuron.C_raw;
for loop=1:10
    % estimate the background components
    neuron=CNMF_CaliAli_update('Background',neuron);
    neuron=CNMF_CaliAli_update('Spatial',neuron);
    neuron=CNMF_CaliAli_update('Temporal',neuron);
    %% post-process the results automatically
    neuron.remove_false_positives();
    neuron.merge_neurons_dist_corr(neuron.show_merge);
    neuron.merge_high_corr(neuron.show_merge,neuron.CaliAli_options.cnmf.merge_thr_spatial);
    neuron.merge_high_corr(neuron.show_merge, [0.9, -inf, -inf]);

    dis=dissimilarity_previous(A_temp,neuron.A,C_temp,neuron.C_raw);
    fprintf('Disimilarity with previous iteration is %.3f\n', dis);

    A_temp=neuron.A;
    C_temp=neuron.C_raw;

    if dis<0.05
        fprintf('CNMF has converged to an estable Solution\n');
        break
    end
end    %% save the workspace for future analysis
% neuron=update_residual_Cn_PNR_batch(neuron);
save_workspace(neuron);



%% Optional post-process
scale_to_noise(neuron);
neuron.C_raw=detrend_Ca_traces(neuron.sf*2,neuron.C_raw,get_batch_size(neuron));
neuron = postprocessDeconvolvedTraces(neuron, 'foopsi','ar2',-5);


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
%   neuron.show_contours(0.9, [], neuron.Cn.*neuron.PNR,0); %PNR*CORR


%% normalized spatial components
% A=neuron.A;A=full(A./max(A,[],1)); A=reshape(max(A,[],2),[size(neuron.Cn,1),size(neuron.Cn,2)]);
% neuron.show_contours(0.6, [], A, 0);

%% to visualize temporal traces
%   figure;strips(neuron.C_raw');
%   figure;stackedplot(neuron.C_raw');
%   view_traces(neuron);

%% Optional post-process
% neuron.merge_high_corr(1, [0.3, 0.2, -inf]);


% ix=postprocessing_app(neuron,0.6);
% neuron.viewNeurons(find(ix), neuron.C_raw);
% neuron.delete(ix);
% save_workspace(neuron);
%% update residuals
% neuron=manually_update_residuals(neuron,use_parallel);



















