function dis=dissimilarity_previous(A1,A2,C1,C2)

sA=create_similarity_matrix_2(full(A1)',full(A2)');
sC=create_similarity_matrix_2(C1,C2);
s=sA.*sC;

[M,ixz,~] = matchpairs(s,0,'max');

ind = sub2ind([size(s,1) size(s,2)],M(:,1),M(:,2));

%  dis=1-mean([sC(ind);zeros(length(ixz),1)]);
dis=1-mean(sC(ind));