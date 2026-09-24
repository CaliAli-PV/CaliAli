function bm_forget_motion_record(files)
%% Reset motion_correction to its defaults, so no trace of the crop survives.
% Not the whole CaliAli_options: a file with none of that is scenario K, and the
% requirement there is that the pipeline REFUSES it. The file here is valid, it
% simply has no history.
fresh = CaliAli_parameters();
for i = 1:numel(files)
    o = CaliAli_load(files{i}, 'CaliAli_options');
    o.motion_correction = fresh.motion_correction;
    CaliAli_save(files{i}, 'CaliAli_options', o);
end
end
