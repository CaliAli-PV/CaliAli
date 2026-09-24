function C = bm_check_non_rigid_does_no_harm(scenarios)
%% bm_check_non_rigid_does_no_harm: Non-rigid correction must cost nothing when there is nothing to correct.
%
% A and F are the same recording and the same options apart from do_non_rigid, and
% that recording only translates. A correctly configured patch correction has
% nothing to find and should land where rigid alone lands.
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
    if ~(have('A') && have('F')), return; end
    a = bm_scenarios(strcmp({scenarios.id},'A'));
    f = bm_scenarios(strcmp({scenarios.id},'F'));

    C{end+1} = bm_chk_true('non-rigid does not blur a recording that does not deform', ...
        f.metrics.crispness_before >= 0.9*a.metrics.crispness_before, ...
        sprintf('crispness %.3f on, %.3f off', ...
        f.metrics.crispness_before, a.metrics.crispness_before));

    C{end+1} = bm_chk_true('and does not cost extraction quality', ...
        f.metrics.auc_f1 >= a.metrics.auc_f1 - 0.05, ...
        sprintf('F1 area %.3f on, %.3f off', f.metrics.auc_f1, a.metrics.auc_f1));
catch ME
    C{end+1} = bm_chk_fail('non-rigid no-harm', ME.message);
end
end
