function cmp = bm_compare_arms(this_arm, other_arm)
%% Join the two arms by scenario and report every metric that moved.
%
% TOLERANCES. Anything that is a count must match exactly -- a differing frame
% or component count is never rounding. The continuous metrics get a small
% tolerance for numerical noise, but not enough to hide a real change.
tol = struct('BV_score',0.05,'corr_before',1e-3,'corr_after',1e-3, ...
    'crispness_before',1e-3,'crispness_after',1e-3, ...
    'auc_f1',0.01,'auc_precision',0.01,'auc_recall',0.01, ...
    'n_sessions',0,'total_frames',0,'n_extracted',0);

cmp = struct('id',{},'metric',{},'this',{},'other',{},'delta',{},'within_tol',{});
for i = 1:numel(this_arm)
    a = this_arm(i);
    j = find(strcmp({other_arm.id}, a.id), 1);
    if isempty(j), continue; end
    b = other_arm(j);
    if isempty(fieldnames(a.metrics)) || isempty(fieldnames(b.metrics)), continue; end
    names = intersect(fieldnames(a.metrics), fieldnames(b.metrics));
    for k = 1:numel(names)
        n = names{k};
        va = a.metrics.(n); vb = b.metrics.(n);
        if ~isnumeric(va) || ~isnumeric(vb) || ~isscalar(va) || ~isscalar(vb), continue; end
        d = double(va) - double(vb);
        if startsWith(n, 'sec_')
            % informational: machine load decides these, not the code
            cmp(end+1) = struct('id',a.id,'metric',n,'this',va,'other',vb, ...
                'delta',d,'within_tol',true); %#ok<AGROW>
            continue
        end
        t = bm_getfield_or(tol, n, 0);
        ok = (isnan(va) && isnan(vb)) || abs(d) <= t;
        cmp(end+1) = struct('id',a.id,'metric',n,'this',va,'other',vb, ...
            'delta',d,'within_tol',ok); %#ok<AGROW>
    end
end
end
