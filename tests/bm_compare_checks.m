function d = bm_compare_checks(this_arm, other_arm)
%% Which checks changed state between the two arms.
%
% This is the point of the exercise. A check that FAILS on main and PASSES here
% is a fix, confirmed on a real run rather than asserted in a commit message. A
% check that passes on main and fails here is a regression, and is the only
% thing in this report that should worry anyone.
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
