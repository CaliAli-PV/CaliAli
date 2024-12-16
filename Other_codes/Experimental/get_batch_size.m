function F=get_batch_size(neuron)

F=neuron.CaliAli_options.inter_session_alignment.F;

if isempty(F)
    F=neuron.frame_range(2);
end

if neuron.CaliAli_options.inter_session_alignment.batch_sz>0
    F=diff( round(  linspace(0,sum(F),round(sum(F)/neuron.CaliAli_options.batch_sz)+1)  )  );
end

end