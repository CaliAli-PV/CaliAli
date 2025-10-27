function F=get_batch_size(neuron)

F=neuron.CaliAli_options.inter_session_alignment.F;

if isempty(F)
    F=neuron.frame_range(2);
end

dims=neuron.P.mat_data.dims;
gF=dims(3);

[chunk, ~] = compute_auto_batch_size(neuron.CaliAli_options.inter_session_alignment.batch_sz,[],[dims(1),dims(2)]);


chunk=round(chunk*0.5); %to account for overlaping patches and other variables

if chunk>0

    if gF<chunk
        fprintf(1, 'The defined batch size (%d) is larger than the number of frames in the video (%d). Processing the entire video in a single batch.\n', ...
            chunk,gF);
        chunk=gF;
    end


    F=diff( round(linspace(0,gF,round(gF/chunk)+1)  )  );
end

%% Sanity check
if sum(F) ~= gF
    fprintf(1, 'Mismatch detected: file contains %d frames, but CaliAli options specify %d frames. Data will be split into the closest matching frame count.\n', ...
        gF,sum(F));
    F = diff(floor(linspace(0, gF, numel(F) + 1)));
end


end