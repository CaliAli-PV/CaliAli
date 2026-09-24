function C = bm_unit_mat_data_cache()
%% bm_unit_mat_data_cache: The patched data must be cached outside the base workspace.
%
% Inputs:
%   None.
%
% Outputs:
%   C - Cell array of check results.

C = {};
try
    mat_data_cache('clear');
    C{end+1} = bm_chk_true('cache starts empty', ~mat_data_cache('has','k'), '');
    mat_data_cache('set','k',struct('a',1));
    C{end+1} = bm_chk_true('cache stores', mat_data_cache('has','k'), '');
    g = mat_data_cache('get','k');
    C{end+1} = bm_chk_true('cache round trip', isstruct(g) && g.a==1, '');
    before = evalin('base','who');
    mat_data_cache('set','k2',rand(5));
    after = evalin('base','who');
    C{end+1} = bm_chk_true('cache creates nothing in base', ...
        isequal(sort(before), sort(after)), '');
    mat_data_cache('clear');
    C{end+1} = bm_chk_true('cache clears', ~mat_data_cache('has','k'), '');
catch ME
    C{end+1} = bm_chk_fail('mat_data_cache', ME.message);
end
end


%% ========================================================================
%  Simulation
%  ========================================================================
