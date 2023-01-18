%% calculate best matching scores.
function [out]=calculate_best_matching_score2(GTa,A,GTc,C)

sA=create_similarity_matrix_2(GTa',A');
sC=create_similarity_matrix_2(GTc,C);
s=sA.*sC;

S=get_max_score(s,sC);



out=S;
end

function out=get_max_score(s,sC)
out=[];
[M,~,ix2] = matchpairs(s,0,'max');
ind = sub2ind([size(s,1) size(s,2)],M(:,1),M(:,2));
M=[M,sC(ind)];
M=[M;cat(2,zeros(size(ix2,1),1),ix2,zeros(size(ix2,1),1))];
out(M(:,2),:)=[M(:,1),M(:,3)];
end

