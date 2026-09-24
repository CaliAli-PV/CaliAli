function C = bm_check_dtype(opt, ds, mc, aligned)
%% The configured class must survive every stage.
% Except the detrended file: get_projections_and_detrend deliberately forces
% uint16 there, so that one is asserted to BE uint16 rather than to match.
want = 'uint16';
try want = lower(char(opt.downsampling.output_class)); catch; end
C = {};
C{end+1} = bm_chk('dtype: _ds.mat', bm_mat_class(ds{1}), want);
if ~isequal(ds, mc)
    C{end+1} = bm_chk('dtype: _mc.mat', bm_mat_class(mc{1}), want);
end
C{end+1} = bm_chk('dtype: _Aligned.mat is uint16 by design', bm_mat_class(aligned), 'uint16');
end
