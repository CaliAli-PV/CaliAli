function W=glob_similarity(C)
fprintf(1, 'Calculating correlation of the %s projections... \n ',P.(3)(1,:).Properties.VariableNames{k});
[d1,d2,d3]=size(C);
C=reshape(C,d1*d2,d3);
Cor=1-squareform(pdist(C','correlation'));
W= rescale(mean(Cor-eye(size(Cor,1)),2))+0.2;
W=W./sum(W);

