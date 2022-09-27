function [similarity_matrix,ids]=construct_similarity_matrix(aligned,probabilities,size_vec)
ids=cell(1,size(aligned,2));
for k=1:length(ids)
    ids{k}=sum(size_vec(1:k-1))+1:sum(size_vec(1:k));
end
similarity_matrix=sparse(sum(size_vec),sum(size_vec));

for k=1:size(aligned,1)
    for j=k+1:size(aligned,2)
        for l=1:size(aligned{k,j},1)
            similarity_matrix(ids{k}(aligned{k,j}(l,1)),ids{j}(aligned{k,j}(l,2)))=probabilities{k,j}(l);
        end
    end
end
similarity_matrix=similarity_matrix+similarity_matrix';


