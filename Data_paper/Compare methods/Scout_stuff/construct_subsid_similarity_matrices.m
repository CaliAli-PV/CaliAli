function [similarity_matrix,ids]=construct_subsid_similarity_matrices(aligned,prob,size_vec,distance_metrics)
ids=cell(1,size(aligned,2));
for k=1:length(ids)
    ids{k}=sum(size_vec(1:k-1))+1:sum(size_vec(1:k));
end
similarity_matrix=sparse(sum(size_vec),sum(size_vec));

for k=1:size(aligned,1)
    for j=k+1:size(aligned,2)
        weights=generate_weights(prob{k,j}{1});
        probabilities{k,j}=extract_weighted_probabilities(weights,prob{k,j}{2},prob{k,j}{3});
        probabilities{k,j}=adjust_identical_probabilities(probabilities{k,j},aligned{k,j},distance_metrics{k,j}{2},'high');
        
        for l=1:size(aligned{k,j},1)
            similarity_matrix(ids{k}(aligned{k,j}(l,1)),ids{j}(aligned{k,j}(l,2)))=probabilities{k,j}(l);
        end
    end
end
similarity_matrix=similarity_matrix+similarity_matrix';