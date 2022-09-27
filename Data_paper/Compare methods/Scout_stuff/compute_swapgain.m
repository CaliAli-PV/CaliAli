function swapgain=compute_swapgain(group_stats,temp_stats,chain_prob,dup_sess,indj,indl,alpha)

%Swaps that create groups with zero similarity are disallowed
if temp_stats.group_one_score(indj)>=1||temp_stats.group_one_score(indl)>=1||...
        dup_sess(indj)||dup_sess(indl)
    swapgain=inf;
    return
end
%No swapping if both new groups are too dissimilar
if temp_stats.group_one_score(indj)>=1-chain_prob||temp_stats.group_score(indj)>=1-chain_prob||...
       temp_stats.group_one_score(indl)>=1-chain_prob||temp_stats.group_score(indl)>=1-chain_prob||...
   min(temp_stats.group_one_score(indl),temp_stats.group_one_score(indj))>min(group_stats.group_one_score(indl),group_stats.group_one_score(indj))
   
   swapgain=inf;
   return
end
 
if group_stats.group_mem(indl)==group_stats.group_mem(indj)
    swapgain=temp_stats.group_one(indj)+temp_stats.group_one(indl)-group_stats.group_one(indj)-group_stats.group_one(indl);
    if temp_stats.group_one(indj)+temp_stats.group_one(indl)<group_stats.group_one(indj)+group_stats.group_one(indl)

        swapgain=temp_stats.group_one(indj)+temp_stats.group_one(indl)-group_stats.group_one(indj)-group_stats.group_one(indl);
    elseif swapgain==0
        swapgain=10^(-2)*(temp_stats.group_score(indj)+temp_stats.group_score(indl)-group_stats.group_score(indj)-group_stats.group_score(indl));
        if (min(temp_stats.group_score(indj),temp_stats.group_score(indl))<min(group_stats.group_score(indj),group_stats.group_score(indl)))
            swapgain=swapgain-alpha;
        elseif min(temp_stats.group_score(indj),temp_stats.group_score(indl))>min(group_stats.group_score(indj),group_stats.group_score(indl))
            swapgain=swapgain+alpha;
        end
        if max(temp_stats.group_one_score(indj),temp_stats.group_score(indj))>=1-chain_prob
            swapgain=swapgain+alpha;
        end
        if max(temp_stats.group_one_score(indl),temp_stats.group_score(indl))>=1-chain_prob
            swapgain=swapgain+alpha;
        end
    else
        swapgain=inf;

    end
elseif group_stats.group_mem(indl)>group_stats.group_mem(indj)&...
        max(temp_stats.group_one_score(indl),temp_stats.group_score(indl))<=1-chain_prob
    if temp_stats.group_one(indl)<group_stats.group_one(indl)
        swapgain=temp_stats.group_one(indl)-group_stats.group_one(indl);
    elseif temp_stats.group_score(indl)<group_stats.group_score(indl)&temp_stats.group_one(indl)==group_stats.group_one(indl)
        swapgain=10^(-2)*(temp_stats.group_score(indl)-group_stats.group_score(indl));
    else
        swapgain=inf;
    end
    if max(temp_stats.group_one_score(indl),temp_stats.group_score(indl))>=1-chain_prob
        swapgain=swapgain+alpha;
    end
    
    
    
elseif group_stats.group_mem(indj)>group_stats.group_mem(indl)&...
        max(temp_stats.group_one_score(indj),temp_stats.group_score(indj))<=1-chain_prob
    if temp_stats.group_one(indj)<group_stats.group_one(indj)
        swapgain=temp_stats.group_one(indj)-group_stats.group_one(indj);
    elseif temp_stats.group_score(indj)<group_stats.group_score(indj)&temp_stats.group_one(indj)==group_stats.group_one(indj)
        swapgain=10^(-2)*(temp_stats.group_score(indj)-group_stats.group_score(indj));
    else
        swapgain=inf;
    end
    if max(temp_stats.group_one_score(indj),temp_stats.group_score(indj))>=1-chain_prob
        swapgain=swapgain+alpha;
    end
else
    swapgain=temp_stats.group_one(indj)+temp_stats.group_one(indl)-group_stats.group_one(indj)-group_stats.group_one(indl)+...
        10^(-2)*(temp_stats.group_score(indj)+temp_stats.group_score(indl)-group_stats.group_score(indj)-group_stats.group_score(indl));
end