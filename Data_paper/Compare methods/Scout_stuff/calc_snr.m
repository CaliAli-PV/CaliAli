function neuron=calc_snr(neuron)
snrs = var(neuron.C, 0, 2)./var(neuron.C_raw-neuron.C, 0, 2);
neuron.SNR=snrs;
end