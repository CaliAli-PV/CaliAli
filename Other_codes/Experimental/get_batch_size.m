function F=get_batch_size(neuron)

F=neuron.CaliAli_options.inter_session_alignment.F;

if isempty(F)
    F=neuron.frame_range(2);
end

dims=neuron.P.mat_data.dims;
gF=dims(3);

[chunk, ~] = compute_auto_batch_size(neuron.CaliAli_options.inter_session_alignment.batch_sz,[],[dims(1),dims(2)]);


mat_data = neuron.P.mat_data;
patch_pos = mat_data.patch_pos;
[nr_patch, nc_patch] = size(patch_pos);
if nr_patch*nc_patch>1
    try
        mult=max(CaliAli_options.cnmf.pars_envs.patch_dims)*CaliAli_options.cnmf.pars_envs.w_overlap/prod(CaliAli_options.cnmf.pars_envs.patch_dims);
    catch
        mult=0.5;
    end
else
mult=0;
end

chunk=chunk+chunk*mult;  %adjust for overlaping patches

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