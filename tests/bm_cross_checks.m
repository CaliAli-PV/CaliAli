function U = bm_cross_checks(scenarios)
%% Checks that only mean something when scenarios are compared with each other.
C = {};
C = [C, bm_check_batch_invariance(scenarios)];
C = [C, bm_check_dark_pixel_costs_nothing(scenarios)];
C = [C, bm_check_non_rigid_does_no_harm(scenarios)];
C = [C, bm_check_non_rigid_helps(scenarios)];
U = [C{:}];
bm_print_checks(U);
end
