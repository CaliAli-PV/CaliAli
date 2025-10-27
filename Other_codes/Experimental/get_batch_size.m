function F=get_batch_size(neuron)

F=neuron.CaliAli_options.inter_session_alignment.F;

if isempty(F)
    F=neuron.frame_range(2);
end

dims=neuron.P.mat_data.dims;
gF=dims(3);

[neuron.CaliAli_options.inter_session_alignment.batch_sz, ~] = compute_auto_batch_size(neuron.CaliAli_options.inter_session_alignment.batch_sz,[],[dims(1),dims(2)]);

neuron.CaliAli_options.inter_session_alignment.batch_sz=neuron.CaliAli_options.inter_session_alignment.batch_sz/2;
if neuron.CaliAli_options.inter_session_alignment.batch_sz>0

    if gF<neuron.CaliAli_options.inter_session_alignment.batch_sz
        fprintf(1, 'The defined batch size (%d) is larger than the number of frames in the video (%d). Processing the entire video in a single batch.\n', ...
            neuron.CaliAli_options.inter_session_alignment.batch_sz,gF);
        neuron.CaliAli_options.inter_session_alignment.batch_sz=gF;
    end


    F=diff( round(linspace(0,gF,round(gF/neuron.CaliAli_options.inter_session_alignment.batch_sz)+1)  )  );
end

%% Sanity check
if sum(F) ~= gF
    fprintf(1, 'Mismatch detected: file contains %d frames, but CaliAli options specify %d frames. Data will be split into the closest matching frame count.\n', ...
        gF,sum(F));
    F = diff(floor(linspace(0, gF, numel(F) + 1)));
end


end