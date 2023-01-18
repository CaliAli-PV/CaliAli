function tau=estimate_time_constant_PV(neuron);

for m=1:size(neuron.C,1)
    temp=ar2exp(estimate_time_constant(neuron.C(m,:), 2));
taud(m,:)=temp;
end