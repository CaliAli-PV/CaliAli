function C = bm_check_bookkeeping(opt, aligned)
%% bm_check_bookkeeping: Frames must be conserved, and alignment must declare how many it has.
%
% Inputs:
%   opt, aligned - Options and the aligned recording.
%
% Outputs:
%   C - Cell array of check results.

C = {};
isa_ = opt.inter_session_alignment;
try
    C{end+1} = bm_chk_true('input_F equals detrend_F', ...
        isequal(isa_.input_F(:), isa_.detrend_F(:)), ...
        sprintf('%s vs %s', mat2str(isa_.input_F(:)'), mat2str(isa_.detrend_F(:)')));
catch
    C{end+1} = bm_chk_fail('input_F equals detrend_F', 'field missing');
end
try
    d = get_data_dimension(aligned);
    C{end+1} = bm_chk_num('aligned frame count equals sum of sessions', ...
        d(3), sum(isa_.F), 0);
catch ME
    C{end+1} = bm_chk_fail('aligned frame count', ME.message);
end
try
    done = CaliAli_load(aligned,'alignment_completed');
    C{end+1} = bm_chk_true('alignment_completed', isequal(done,true), '');
catch
    C{end+1} = bm_chk_fail('alignment_completed', 'flag missing');
end
end
