function [aligned_neurons,probabilities]=Eliminate_Repeats_No_Fill(aligned_neurons,probabilities)

[repeated,total]=repeated_elements(aligned_neurons);
if total==0
    return
end
for k=1:size(aligned_neurons,2)
    for j=1:length(repeated{k})
        poss_ind=find(aligned_neurons(:,k)==repeated{k}(j));
        lengths=[];
        scores=[];
        for l=1:length(poss_ind)
            lengths(l)=sum(aligned_neurons(poss_ind(l),:)==0);
            
        end
        ind=find(lengths==min(lengths));
        bad_ind=setdiff(poss_ind,poss_ind(ind));
        poss_ind=poss_ind(ind);
        [M,I]=max(probabilities(poss_ind));
        bad_ind=[bad_ind;setdiff(poss_ind,poss_ind(I))];
        aligned_neurons(bad_ind,k)=0;
    end
end

    
    
    
    
    
    
    
    
    
end

function [repeated,total]=repeated_elements(aligned_neurons);
repeated={};
total=0;
for k=1:size(aligned_neurons,2)
    [GC,GR] = groupcounts(aligned_neurons(:,k));
    rep=find(GC>1&GR>1);
    repeated{k}=GR(rep);
    total=total+length(rep);
end
end
