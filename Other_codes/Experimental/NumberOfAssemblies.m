function N = NumberOfAssemblies(S)
S(:,sum(S,1)==0)=[];
S(sum(S,2)==0,:)=[];
CorrMatrix = corr(S);
CorrMatrix(isnan(CorrMatrix))=0;
[~,d] = eig(CorrMatrix);
d=real(d);
eigenvalues=diag(d);
%Marchenko–Pastur
q = size(S,1)/size(S,2);
lambda_max = ((1+sqrt(1/q))^2);
% lambda_max = prctile(circular_shift(S',1000),95);
N = sum(eigenvalues>lambda_max);
%N = sum(eigenvalues>1);
end

