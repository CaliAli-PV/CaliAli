function C = bm_check_non_rigid_does_no_harm(scenarios)
%% Switching non-rigid correction on must not cost anything when there is
%% nothing for it to correct.
%
% A and F are the same recording and the same options apart from do_non_rigid,
% and that recording's within-session motion is pure translation. So a correctly
% parameterised patch correction has nothing to find, should estimate almost
% nothing, and should land where rigid alone lands. Any real loss here is the
% patches warping the frame on no evidence -- which is a parameter problem, most
% often an overlap or a max_dev that did not scale with the patch size.
%
% The tolerances are deliberately loose. This is not asking the correction to be
% good, only to be harmless: an extra resampling pass over every pixel costs a
% little blur whatever the field is, and that much is unavoidable.
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
