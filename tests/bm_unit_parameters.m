function C = bm_unit_parameters()
%% bm_unit_parameters: Name/value pairs must survive being parsed.
%
% Inputs:
%   None.
%
% Outputs:
%   C - Cell array of check results.

C = {};
try
    o = CaliAli_parameters('batch_sz', 250, 'spatial_ds', 2);
    C{end+1} = bm_chk_num('two name/value pairs: batch_sz', o.downsampling.batch_sz, 250, 0);
    C{end+1} = bm_chk_num('two name/value pairs: spatial_ds', o.downsampling.spatial_ds, 2, 0);
catch ME
    C{end+1} = bm_chk_fail('two name/value pairs', ME.message);
end
try
    CaliAli_parameters('batch_sz');
    C{end+1} = bm_chk_fail('odd argument count rejected', 'no error raised');
catch
    C{end+1} = bm_chk_true('odd argument count rejected', true, '');
end
try
    o = CaliAli_parameters();
    o.inter_session_alignment.Cn_scale_per_session = [0.2;0.3];
    o.inter_session_alignment.projection_method = 'greedy';
    o2 = CaliAli_parameters(o);
    C{end+1} = bm_chk_true('new projection fields survive a round trip', ...
        isequal(o2.inter_session_alignment.Cn_scale_per_session,[0.2;0.3]) && ...
        strcmp(o2.inter_session_alignment.projection_method,'greedy'), '');
catch ME
    C{end+1} = bm_chk_fail('projection fields round trip', ME.message);
end
end
