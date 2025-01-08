function neuron=manually_update_residuals(neuron,use_parallel)

seed_all=get_seed(neuron);
neuron=update_temporal_CaliAli(neuron, use_parallel);
neuron=update_residual_custom_seeds(neuron,seed_all);

A_temp=neuron.A;
C_temp=neuron.C_raw;
for loop=1:10
    % estimate the background components
    neuron=update_background_CaliAli(neuron, use_parallel);
    neuron=update_spatial_CaliAli(neuron, use_parallel);
    neuron=update_temporal_CaliAli(neuron, use_parallel);
    dis=dissimilarity_previous(A_temp,neuron.A,C_temp,neuron.C_raw);
    A_temp=neuron.A;
    C_temp=neuron.C_raw;
    dis
    if dis<0.05
        break
    end
end

%% post-process the results automatically
neuron.remove_false_positives();

neuron=update_residual_Cn_PNR(neuron);

%% Optional post-process
scale_to_noise(neuron);
neuron.C_raw=detrend_Ca_traces(neuron.Fs*2,neuron.C_raw);
justdeconv(neuron,'thresholded','ar2',0);
denoise_thresholded(neuron,3);

