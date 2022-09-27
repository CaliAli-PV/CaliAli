function consensus_matrix=construct_consensus(idx,used,total_ind,xDist,num_sessions)
consensus_matrix=zeros(total_ind,total_ind);
denominator=zeros(total_ind,total_ind);
weights=zeros(1,length(idx));
for j=1:length(idx)
    for k=1:max(idx{j})
        nodes=find(idx{j}==k);
        weights(j)=weights(j)+mean(xDist(nodes,nodes),'all')*10^(-(num_sessions-length(nodes)));
    end
end
weights=weights/sum(weights);
    


    

for j=1:length(idx)
    for p1=1:length(used{j})
        for p2=1:length(used{j})
            denominator(used{j}(p1),used{j}(p2))=denominator(used{j}(p1),used{j}(p2))+1;
        end
    end
    for k=1:max(idx{j})
        consensus_matrix(used{j}(idx{j}==k),used{j}(idx{j}==k))=consensus_matrix(used{j}(idx{j}==k),used{j}(idx{j}==k))+1;
    end
end
consensus_matrix=consensus_matrix./denominator;

        
        