function U = bm_cross_checks(scenarios)
%% bm_cross_checks: Run the checks that compare scenarios with each other.
%
% Inputs:
%   scenarios - The records from bm_run_scenarios.
%
% Outputs:
%   U - Structure array of check results.

C = {};
C = [C, bm_check_batch_invariance(scenarios)];
C = [C, bm_check_dark_pixel_costs_nothing(scenarios)];
C = [C, bm_check_non_rigid_does_no_harm(scenarios)];
C = [C, bm_check_non_rigid_helps(scenarios)];
U = [C{:}];
bm_print_checks(U);
end
