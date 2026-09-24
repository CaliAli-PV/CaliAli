function mc = bm_correct_each_session_alone(ds, opt)
%% bm_correct_each_session_alone: Motion-correct each session on its own, then erase the record.
%
% Inputs:
%   ds, opt - The downsampled files and the options.
%
% Outputs:
%   mc - The corrected files.

mc = cell(1, numel(ds));
for i = 1:numel(ds)
    o = opt;
    o.motion_correction.input_files  = ds(i);
    o.motion_correction.output_files = [];
    o = CaliAli_motion_correction(o);
    mc{i} = o.motion_correction.output_files{1};
end
bm_forget_motion_record(mc);
end
