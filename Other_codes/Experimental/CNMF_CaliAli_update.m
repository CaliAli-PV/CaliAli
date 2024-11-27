
function neuron=CNMF_CaliAli_update(component_name,neuron,F)

use_parallel=neuron.use_parallel;
if ~(exist('F','var') && ~isempty(F))
    F=get_batch_size(neuron,0);
end

switch component_name
    case 'Spatial'
        if neuron.CaliAli_opt.dynamic_spatial==1
            neuron=update_spatial_CaliAli_dynamic_spatial(neuron, use_parallel,F);
        else
            neuron=update_spatial_CaliAli(neuron, use_parallel,F);
        end
    case 'Temporal'
        if neuron.CaliAli_opt.dynamic_spatial==1
            neuron=update_temporal_CaliAli_dynamic_spatial(neuron, use_parallel,F);
        else
            neuron=update_temporal_CaliAli(neuron, use_parallel,F);
        end
    case 'Background'
        if neuron.CaliAli_opt.dynamic_spatial==1
            neuron=update_background_CaliAli_dynamic_spatial(neuron, use_parallel,F);
        else
            neuron=update_background_CaliAli(neuron, use_parallel,F);
        end
    otherwise
          disp('Please set component name to ''Spatial'',''Temporal'' or, ''Background'' ');
end