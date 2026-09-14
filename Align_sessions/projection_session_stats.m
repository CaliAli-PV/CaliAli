function stats = projection_session_stats(P, preprocessing)
%% projection_session_stats: Keep the per-session projections instead of collapsing them.
%
% The alignment computes a correlation and a peak-to-noise image for every
% session, then reduces them to one image with max(...,[],3) and one scalar
% Cn_scale for the whole recording. That is enough to normalise the recording as
% a whole, but it discards what a later stage needs.
%
% WHY IT IS NEEDED. update_residual_Cn_PNR_batch divides its residual
% correlation image by Cn_scale so that min_corr means the same thing there as
% at initialization. Cn_scale is the peak over EVERY session, so for a session
% whose own peak is lower the residual image is divided by too large a number,
% and min_corr becomes a different threshold than it was at initialization. When
% a session is appended, the appended session is exactly the one whose own peak
% is wanted. Recording it here avoids recomputing an image the alignment has
% already produced.
%
% WHAT IS RECORDED. The per-session images as they are, their individual peaks,
% and the settings that produced them -- because the residual path computes its
% image with the same function but different preprocessing, and can only be made
% comparable if it knows which steps to match.
%
% Inputs:
%   P             - the alignment projections table
%   preprocessing - CaliAli_options.preprocessing, for the settings used
%
% Output:
%   stats - struct with fields:
%     .Cn_per_session        d1 x d2 x n_sessions, raw correlation, aligned grid
%     .PNR_per_session       d1 x d2 x n_sessions, raw peak-to-noise
%     .Cn_scale_per_session  n_sessions x 1, each session's own peak correlation
%     .PNR_scale_per_session n_sessions x 1, each session's own peak
%     .projection_method     'fastPNR', 'dendrite' or 'greedy'
%     .projection_median_filtering  medfilt2 size, or [] when none was applied
%
% Author: Pablo Vergara

Cn_all  = P.(size(P, 2))(1, :).(3){1, 1};
PNR_all = P.(size(P, 2))(1, :).(4){1, 1};

stats.Cn_per_session  = single(Cn_all);
stats.PNR_per_session = single(PNR_all);
stats.Cn_scale_per_session  = squeeze(max(max(Cn_all,  [], 1), [], 2));
stats.PNR_scale_per_session = squeeze(max(max(PNR_all, [], 1), [], 2));
stats.Cn_scale_per_session  = stats.Cn_scale_per_session(:);
stats.PNR_scale_per_session = stats.PNR_scale_per_session(:);

% Which branch of get_projections_and_detrend produced these, so the residual
% path can reproduce the same preprocessing rather than assume it.
method = 'greedy';
med = [];
if isstruct(preprocessing)
    if isfield(preprocessing, 'fastPNR') && preprocessing.fastPNR
        method = 'fastPNR';
    elseif isfield(preprocessing, 'structure') && strcmpi(preprocessing.structure, 'dendrite')
        method = 'dendrite';
    end
    if isfield(preprocessing, 'median_filtering')
        med = preprocessing.median_filtering;
    end
end
stats.projection_method = method;
stats.projection_median_filtering = med;
end
