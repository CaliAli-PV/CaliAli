function C = bm_check_dtype(opt, ds, mc, aligned)
%% bm_check_dtype: The configured datatype must survive every stage.
%
% Inputs:
%   opt, ds, mc, aligned - Options and the files each stage wrote.
%
% Outputs:
%   C - Cell array of check results.

want = 'uint16';
try want = lower(char(opt.downsampling.output_class)); catch; end
C = {};
C{end+1} = bm_chk('dtype: _ds.mat', bm_mat_class(ds{1}), want);
if ~isequal(ds, mc)
    C{end+1} = bm_chk('dtype: _mc.mat', bm_mat_class(mc{1}), want);
end
C{end+1} = bm_chk('dtype: _Aligned.mat is uint16 by design', bm_mat_class(aligned), 'uint16');
end
