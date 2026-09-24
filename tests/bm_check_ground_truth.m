function [C, score] = bm_check_ground_truth(extraction, sim, opt)
%% bm_check_ground_truth: Score the extraction against what was simulated.
%
% Inputs:
%   extraction, sim, opt - The result, the ground truth and the options.
%
% Outputs:
%   C - Cell array of check results.

C = {}; score = [];
try
    L = load(extraction,'neuron');
    n = L.neuron;
    nrn = struct('A',n.A,'C',n.C,'C_raw',n.C_raw, ...
        'options',struct('d1',n.options.d1,'d2',n.options.d2));
    % Explicit factors: evaluate_extraction cannot read them off a plain struct
    % and would silently assume 1.
    r = evaluate_extraction(nrn, sim.meta, 'trace','C', ...
        'spatial_ds', opt.downsampling.spatial_ds, ...
        'temporal_ds', opt.downsampling.temporal_ds, ...
        'per_session', true, 'verbose', false);
    score = struct('auc_f1',r.auc_f1,'auc_precision',r.auc_precision, ...
        'auc_recall',r.auc_recall,'n_extracted',r.n_extracted_total, ...
        'n_gt',r.n_gt_total,'per_session',[r.per_session.auc_f1]);
    C{end+1} = bm_chk_true('extraction found components', r.n_extracted_total > 0, ...
        sprintf('%d', r.n_extracted_total));
    % No absolute threshold is asserted here. These changes are procedural, so
    % the meaningful question is not "is F1 good" but "is F1 the same as it was
    % on main". That comparison happens in compare_arms, against the other arm
    % of the same scenario on the same simulated recording.
catch ME
    C{end+1} = bm_chk_fail('ground truth scoring', ME.message);
end
end


%% ========================================================================
%  Unit checks
%  ========================================================================
