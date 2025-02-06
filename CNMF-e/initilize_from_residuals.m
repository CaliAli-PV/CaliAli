function neuron = initilize_from_residuals(neuron)

%% start initialization
if strcmp(neuron.CaliAli_options.preprocessing.structure,'neuron')
    [A,C_raw,C,S] = int_temp_batch(neuron);
elseif strcmp(neuron.CaliAli_options.preprocessing.structure,'dendrite')
    [A,C_raw,C,S] = int_temp_batch_dendrite_residual(neuron);
end

fprintf('%.0f new neurons were initilized from the residual video\n',size(A,2));
%% export the results
neuron.A = [neuron.A,A];
neuron.C = [neuron.C;C];
neuron.C_raw = [neuron.C_raw;C_raw];
neuron.S = [neuron.S;sparse(S)];
K = size(neuron.A, 2);
neuron.P.k_ids = K;
neuron.ids = (1:K);
neuron.tags = zeros(K,1, 'like', uint16(0));
fprintf('Finished the initialization from residual procedure.\n');
