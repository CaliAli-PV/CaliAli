function C = bm_check_workspace(sentinel)
%% bm_check_workspace: The pipeline must not create or destroy variables in the base workspace.
%
% Inputs:
%   sentinel - A value placed in the base workspace before the run.
%
% Outputs:
%   C - Cell array of check results.

C = {};
try
    still = evalin('base','exist(''caliali_benchmark_sentinel'',''var'')');
    C{end+1} = bm_chk_true('base workspace variable survived', still==1, '');
    if still==1
        got = evalin('base','caliali_benchmark_sentinel');
        C{end+1} = bm_chk_true('base workspace variable unchanged', isequal(got,sentinel), '');
    end
    names = evalin('base','who');
    leaked = names(startsWith(names,'mat_data'));
    C{end+1} = bm_chk_true('no mat_data_* left in base', isempty(leaked), strjoin(leaked',','));
    evalin('base','clear caliali_benchmark_sentinel');
catch ME
    C{end+1} = bm_chk_fail('base workspace', ME.message);
end
end
