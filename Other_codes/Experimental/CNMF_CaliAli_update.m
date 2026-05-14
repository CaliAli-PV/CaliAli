function neuron=CNMF_CaliAli_update(component_name,neuron,ret_id,F)

use_parallel=neuron.use_parallel;
if ~(exist('F','var') && ~isempty(F))
    F=get_batch_size(neuron);
end
if ~(exist('ret_id','var'))
    ret_id=[];
end
[ret_id, ~]=normalize_retired_ids(neuron, ret_id);

switch component_name
    case 'Spatial'
        neuron=update_spatial_CaliAli(neuron, use_parallel,ret_id,F);
    case 'Temporal'
        neuron=update_temporal_CaliAli(neuron, use_parallel,ret_id,F);
    case 'Background'
        neuron=update_background_CaliAli(neuron, use_parallel,ret_id,F);
    otherwise
        disp('Please set component name to ''Spatial'',''Temporal'' or, ''Background'' ');
end
