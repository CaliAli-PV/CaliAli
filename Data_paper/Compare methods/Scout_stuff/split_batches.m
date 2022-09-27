function C=split_batches(C,similarity_matrix,k,num_sessions)


tom=getTopologicalSimilarity(similarity_matrix,2);



num_nodes=ceil(length(C{k})/(6*num_sessions));
vals_per_node=ceil(size(tom,1)/num_nodes);
unused=1:length(C{k});
split={};
while length(unused)>0 
    node_sum=sum(tom,2);
    node_sum(setdiff(1:length(C{k}),unused))=-inf;
    [M,I]=max(node_sum);
    [~,order]=sort(tom(I,:),'descend');
    order(tom(I,order)<0)=[];
    split{end+1}=order(1:min(length(order),vals_per_node));
    tom(order(1:min(length(order),vals_per_node)),order(1:min(length(order),vals_per_node)))=-10^(-7);
    unused=setdiff(unused,order(1:min(length(order),vals_per_node)));
    
end
for j=1:length(split)
    for l=1:length(split{j})
        split{j}=[split{j},find(similarity_matrix(split{j}(l),:)>0)];
    end
    split{j}=unique(split{j});
    split{j}=C{k}(split{j});
end
C(k)=[];
for j=1:length(split)
    C{end+1}=split{j};
end


