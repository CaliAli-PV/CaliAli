function C = bm_check_non_rigid_helps(scenarios)
%% On a recording that deforms, correcting the deformation must be worth doing.
%
% F1 and F2 are the same simulation and the same options apart from
% do_non_rigid, so any difference between them is the non-rigid pass and nothing
% else. This is the check the old scenario F could never make: it ran on a
% recording whose within-session motion was pure translation, where the non-rigid
% pass has nothing to find and can only lose.
%
% Crispness is the measure, not correlation between sessions. Deformation is a
% WITHIN-session defect: it blurs each session's own projections, and crispness
% is what reads that directly. A correction that undoes it sharpens the
% projections it is handed.
C = {};
try
    have = @(x) any(strcmp({scenarios.id},x) & [scenarios.ok]);
    if ~(have('F1') && have('F2'))
        return   % not both run; nothing to compare, and not a failure
    end
    a = bm_scenarios(strcmp({scenarios.id},'F1'));
    b = bm_scenarios(strcmp({scenarios.id},'F2'));

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
