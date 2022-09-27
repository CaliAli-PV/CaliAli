function [aligned_neurons,aligned_probabilities]=split_cell_register(aligned_neurons,probabilities,aligned,dist_vals,...
    min_prob,method,penalty,max_sess_dist,use_spat,chain_prob)

removed={};
prob=construct_combined_probabilities_adj(aligned_neurons(1,:),probabilities,aligned,dist_vals,min_prob,[],[],max_sess_dist);
while max(prob<chain_prob)
    prob_score=[];
for k=1:size(aligned_neurons,2);
    temp=aligned_neurons(1,:);
    if temp(k)~=0
        temp(k)=0;
    
    if use_spat
        prob_score(k)=construct_combined_probabilities_adj(temp,probabilities,aligned,dist_vals,min_prob,[],[],max_sess_dist);
    else
        prob_score(k)=construct_consecutive_probabilities(aligned_neurons,probabilities,pair_aligned);
    end
    end
end
[prob,I]=max(prob_score);
removed{end+1}=[I,aligned_neurons(1,I)];
aligned_neurons(I)=0;
end
if length(removed)>0
    resid=zeros(1,size(aligned_neurons,2));
    for k=1:length(removed)
        resid(removed{k}(1))=removed{k}(2);
    end
    temp_aligned=split_cell_register(resid,probabilities,aligned,dist_vals,...
        min_prob,method,penalty,max_sess_dist,use_spat,chain_prob);

    aligned_neurons=[aligned_neurons;temp_aligned];
end
    

