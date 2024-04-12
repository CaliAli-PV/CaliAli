function control_max_eig = circular_shift(SpikeCount,number_of_surrogates)

control_max_eig=zeros(1,number_of_surrogates);
for surr_idx = 1:number_of_surrogates
    ControlSpikeCount=zeros(size(SpikeCount));
    for neuron_idx = 1:size(SpikeCount,1)
        drawnbin = randi(size(SpikeCount,2),1);
        auxbin = [drawnbin:size(SpikeCount,2) 1:drawnbin-1];
        ControlSpikeCount(neuron_idx,:) = SpikeCount(neuron_idx,auxbin);
    end
    CorrelationMatrix = corr(ControlSpikeCount');
    CorrelationMatrix(isnan(CorrelationMatrix))=0;
    [~,eigenvalues]=eig(CorrelationMatrix);
    control_max_eig(surr_idx)=max(reshape(eigenvalues,1,[]));
end