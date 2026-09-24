function mc = bm_correct_each_session_alone(ds, opt)
%% Motion-correct every session on its own, then erase the record of how.
%
% Correcting them one at a time is what makes this different from the normal
% path: each session is cropped to ITS OWN valid region, so the crop is a
% different size and sits at a different place in the original frame. Stripping
% motion_correction afterwards removes the only thing that says where -- the
% Mask, which CaliAli keeps at the pre-crop size with the kept rectangle marked.
% What reaches alignment is then exactly what an external tool hands over:
% corrected sessions of different sizes, off centre from each other, with nothing
% recorded about the padding.
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
