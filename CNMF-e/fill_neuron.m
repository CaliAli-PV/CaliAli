function neuron = fill_neuron(neuron, pars)
% Fills structure A with matching fields from structure B.

fields_B = fieldnames(pars);

for i = 1:numel(fields_B)
    field_name = fields_B{i};
    if isprop(neuron, field_name)||isfield(neuron, field_name)
        neuron.(field_name) = pars.(field_name);
    end
end

end