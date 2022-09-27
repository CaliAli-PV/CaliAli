function [group_stats]=compute_group_stats(assign,xDist,k)

for j=1:k
    group_mem(j)=sum(assign==j);
    group_score(j)=sum(xDist(assign==j,assign==j),'all')/((group_mem(j)^2-group_mem(j)));
    group_one(j)=sum(xDist(assign==j,assign==j)>=1,'all');
    group_score(isnan(group_score))=0;
    if group_mem(j)<=1
        group_one_score(j)=0;
    else
        group_one_score(j)=group_one(j)/(group_mem(j)^2-group_mem(j));
    end
end
group_stats.group_mem=group_mem;
group_stats.group_score=group_score;
group_stats.group_one=group_one;
group_stats.group_one_score=group_one_score;