function C = bm_check_alignment(opt, aligned)
%% The alignment metrics must improve, and the vessel score must clear its gate.
C = {};
isa_ = opt.inter_session_alignment;
try
    t = isa_.alignment_metrics;
    score = t.("Mean Corr. Score");
    if iscell(score), score = cell2mat(score); end
    C{end+1} = bm_chk_true('alignment improves correlation', ...
        all(diff(score) >= -1e-6), mat2str(score(:)',4));
catch ME
    C{end+1} = bm_chk_fail('alignment_metrics', ME.message);
end
try
    bv = isa_.BV_score;
    % Below 2.7 the whole alignment is redone from neurons instead of vessels.
    % That is a different branch, so any comparison against another arm stops
    % being meaningful -- worth knowing about rather than silently passing.
    C{end+1} = bm_chk_true('BV_score above the neuron-fallback gate', bv >= 2.7, ...
        sprintf('%.2f', bv));
catch ME
    C{end+1} = bm_chk_fail('BV_score', ME.message);
end
% Cn, Cn_scale, PNR and the per-session projections are written by
% save_relevant_variables, which takes CaliAli_options BY VALUE and returns
% nothing. They exist only in the saved file, never in the struct the caller
% gets back -- so they have to be read from the file.
try
    stored = CaliAli_load(aligned, 'CaliAli_options');
    sa = stored.inter_session_alignment;
    C{end+1} = bm_chk_num('per-session projections recorded', ...
        numel(sa.Cn_scale_per_session), numel(sa.F), 0);
    C{end+1} = bm_chk_num('per-session images recorded', ...
        size(sa.Cn_per_session,3), numel(sa.F), 0);
    C{end+1} = bm_chk_true('projection method recorded', ...
        ischar(sa.projection_method) && ~isempty(sa.projection_method), ...
        char(sa.projection_method));
    C{end+1} = bm_chk_true('per-session peaks are positive', ...
        all(sa.Cn_scale_per_session > 0), mat2str(sa.Cn_scale_per_session(:)',4));
catch ME
    C{end+1} = bm_chk_fail('per-session projections', ME.message);
end
end
