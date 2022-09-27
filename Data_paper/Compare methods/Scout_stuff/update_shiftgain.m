function shiftgain=update_shiftgain(shiftgain,ind_old,ind_new,group_stats,temp_stats,chain_prob,alpha);

%Prevent decreasing group size if original group has sufficiently high
%similarity
if temp_stats.group_mem(ind_new)<group_stats.group_mem(ind_old)&...
        group_stats.group_one_score(ind_old)<=1-chain_prob&...
        group_stats.group_score(ind_old)<=1-chain_prob
      shiftgain=shiftgain+1000;
end


%Prevent shifting if largest group in new grouping has higher score (only
%matters if group sizes are the same in the end)
if group_stats.group_mem(ind_old)==temp_stats.group_mem(ind_new)&(group_stats.group_one(ind_old)+...
        10^(-2)*group_stats.group_score(ind_old))<=(temp_stats.group_one(ind_new)+10^(-2)*temp_stats.group_score(ind_new))
        shiftgain=shiftgain+1000;
end

%If new group has increased size, force shifting so long as new group has high
%similarity
if (group_stats.group_mem(ind_new)>=group_stats.group_mem(ind_old)...
        &(temp_stats.group_one_score(ind_new)<=1-chain_prob&...
        temp_stats.group_score(ind_new)<=1-chain_prob))
    shiftgain=-1000+shiftgain;
end
%If old group is too dissimilar, bias toward shifting
if group_stats.group_one_score(ind_old)>=1-chain_prob||group_stats.group_score(ind_old)>=1-chain_prob
    shiftgain=shiftgain-alpha;
end
%Prevent formation of clusters with no similarity
if temp_stats.group_one_score(ind_old)==1||temp_stats.group_one_score(ind_new)==1
    shiftgain=inf;
end
