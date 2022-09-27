function neuron=estimate_decay_full(neuron)
for k=1:size(neuron.C_raw,1)
    decay(k)=estimate_decay_rate_from_signal(neuron,k);
end
%decay(isnan(decay))=1;
neuron.P.kernel_pars=1+decay';
end