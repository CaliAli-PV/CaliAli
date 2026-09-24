function bm_forget_motion_record(files)
%% bm_forget_motion_record: Reset motion_correction to its defaults in each file.
%
% Inputs:
%   files - The files to strip.
%
% Outputs:
%   None.

fresh = CaliAli_parameters();
for i = 1:numel(files)
    o = CaliAli_load(files{i}, 'CaliAli_options');
    o.motion_correction = fresh.motion_correction;
    CaliAli_save(files{i}, 'CaliAli_options', o);
end
end
