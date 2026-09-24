function U = bm_unit_checks()
%% bm_unit_checks: Run the checks that need no simulated data.
%
% These test one component at a time, so a failure points at that component
% rather than at the pipeline.
%
% Inputs:
%   None.
%
% Outputs:
%   U - Structure array of check results.

C = {};
C = [C, bm_unit_check_mat_video()];
C = [C, bm_unit_parameters()];
C = [C, bm_unit_parameter_divergence()];
C = [C, bm_unit_batch_modes()];
C = [C, bm_unit_translation_bound()];
C = [C, bm_unit_w_overlap()];
C = [C, bm_unit_mat_data_cache()];
U = [C{:}];
bm_print_checks(U);
end
