function F=get_batch_size(neuron)


F=neuron.CaliAli_opt.inter_session_alignment.F;

if neuron.CaliAli_opt.inter_session_alignment.batch_sz>0
    F=diff( round(  linspace(0,sum(F),round(sum(F)/neuron.CaliAli_opt.batch_sz)+1)  )  );
end

end