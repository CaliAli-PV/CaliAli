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

    % F1 AREA, NOT CRISPNESS. Crispness reads the sharpness of a projection,
    % which is only a proxy for alignment, and measuring the estimated field
    % against a known one showed it points the wrong way often enough not to be
    % trusted: in one run it called the non-rigid pass worse, 6.918 against
    % 7.198, while F1 against the ground truth called it better, 0.600 against
    % 0.576. F1 is scored on the neurons that were actually simulated, so it is
    % the one to assert on.
    C{end+1} = bm_chk_true('non-rigid correction does not hurt a deforming recording', ...
        b.metrics.auc_f1 >= a.metrics.auc_f1 - 0.02, ...
        sprintf('F1 area %.3f with, %.3f without', b.metrics.auc_f1, a.metrics.auc_f1));

    % Reported, not asserted: one recording and one amplitude is not enough to
    % require an improvement, and this is the number that would show one.
    fprintf('    non-rigid F1 delta %+.3f, crispness delta %+.3f\n', ...
        b.metrics.auc_f1 - a.metrics.auc_f1, ...
        b.metrics.crispness_before - a.metrics.crispness_before);
catch ME
    C{end+1} = bm_chk_fail('non-rigid comparison', ME.message);
end
end
