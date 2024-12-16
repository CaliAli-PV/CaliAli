function neuron=CNMF_CaliAli_update(component_name,neuron,F)

use_parallel=neuron.use_parallel;
if ~(exist('F','var') && ~isempty(F))
    F=get_batch_size(neuron);
end

switch component_name
    case 'Spatial'
        neuron=update_spatial_CaliAli(neuron, use_parallel,F);
    case 'Temporal'
        neuron=update_temporal_CaliAli(neuron, use_parallel,F);
    case 'Background'
        neuron=update_background_CaliAli(neuron, use_parallel,F);
    otherwise
        disp('Please set component name to ''Spatial'',''Temporal'' or, ''Background'' ');
end