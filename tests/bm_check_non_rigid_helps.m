function C = bm_check_non_rigid_helps(scenarios)
%% bm_check_non_rigid_helps: On a recording that deforms, correcting the deformation must be worth doing.
%
% F1 and F2 are the same simulation and the same options apart from do_non_rigid,
% so any difference between them is the non-rigid pass and nothing else.
%
% Inputs:
%   scenarios - The records from bm_run_scenarios.
%
% Outputs:
%   C - Cell array of check results.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

C = {};
try
    have = @(x) any(strcmp({scenarios.id},x) & [scenarios.ok]);
    if ~(have('F1') && have('F2'))
        return   % not both run; nothing to compare, and not a failure
    end
    a = scenarios(strcmp({scenarios.id},'F1'));
    b = scenarios(strcmp({scenarios.id},'F2'));

    C{end+1} = bm_chk_true('non-rigid correction sharpens a deforming recording', ...
        b.metrics.crispness_before >= a.metrics.crispness_before, ...
        sprintf('crispness %.3f with, %.3f without', ...
        b.metrics.crispness_before, a.metrics.crispness_before));

    C{end+1} = bm_chk_true('and does not cost extraction quality', ...
        b.metrics.auc_f1 >= a.metrics.auc_f1 - 0.02, ...
        sprintf('F1 area %.3f with, %.3f without', b.metrics.auc_f1, a.metrics.auc_f1));
catch ME
    C{end+1} = bm_chk_fail('non-rigid comparison', ME.message);
end
end
