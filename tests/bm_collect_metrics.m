function m = bm_collect_metrics(opt, score, timing)
%% Every number worth putting side by side with the other arm.
%
% These changes are procedural, so the expectation is EQUALITY, not improvement.
% A difference in any of these is the finding: it means a change that was only
% supposed to move files around also moved a number.
m = struct();
isa_ = opt.inter_session_alignment;

m.BV_score = bm_getfield_or(isa_, 'BV_score', NaN);
try
    t = isa_.alignment_metrics;
    v = t.("Mean Corr. Score"); if iscell(v), v = cell2mat(v); end
    m.corr_before  = v(1);
    m.corr_after   = v(end);
    c = t.("Crispness"); if iscell(c), c = cell2mat(c); end
    m.crispness_before = c(1);
    m.crispness_after  = c(end);
catch
    m.corr_before = NaN; m.corr_after = NaN;
    m.crispness_before = NaN; m.crispness_after = NaN;
end
m.n_sessions = numel(bm_getfield_or(isa_,'F',[]));
m.total_frames = sum(bm_getfield_or(isa_,'F',NaN));

if ~isempty(score)
    m.auc_f1        = score.auc_f1;
    m.auc_precision = score.auc_precision;
    m.auc_recall    = score.auc_recall;
    m.n_extracted   = score.n_extracted;
else
    m.auc_f1 = NaN; m.auc_precision = NaN; m.auc_recall = NaN; m.n_extracted = NaN;
end

% Timings are compared but never asserted: they vary with the machine and its
% load, so a tolerance would be either meaningless or permanently red. They are
% reported as a ratio so a stage that changed materially is still visible.
if nargin > 2 && ~isempty(timing)
    m.sec_downsample        = timing.downsample;
    m.sec_motion_correction = timing.motion_correction;
    m.sec_alignment         = timing.alignment;
    m.sec_extraction        = timing.extraction;
    m.sec_total             = timing.total;
end
end
