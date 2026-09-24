function d = bm_compare_checks(this_arm, other_arm)
%% bm_compare_checks: Report which checks changed state between the two arms.
%
% Inputs:
%   this_arm, other_arm - The scenario records from each arm.
%
% Outputs:
%   d - One entry per check that was fixed or broken.

d = struct('id',{},'name',{},'this',{},'other',{},'verdict',{});
for i = 1:numel(this_arm)
    a = this_arm(i);
    j = find(strcmp({other_arm.id}, a.id), 1);
    if isempty(j) || isempty(a.checks), continue; end
    b = other_arm(j);
    if isempty(b.checks), continue; end
    for k = 1:numel(a.checks)
        n = a.checks(k).name;
        m = find(strcmp({b.checks.name}, n), 1);
        if isempty(m), continue; end
        pa = a.checks(k).pass; pb = b.checks(m).pass;
        if pa == pb, continue; end
        d(end+1) = struct('id',a.id,'name',n,'this',pa,'other',pb, ...
            'verdict',bm_tern(pa,'FIXED','REGRESSED')); %#ok<AGROW>
    end
end
end
