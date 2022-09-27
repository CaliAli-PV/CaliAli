function weights=generate_weights(weights)
% weights=zeros(length(n));
% perm=randperm(n);
% 
% for j=1:n-1
%     randval=unifrnd(0,1-sum(weights));
%     weights(perm(j))=unifrnd(0,1-sum(weights)-randval);
%     
% end
% weights(perm(end))=1-sum(weights);
ind=weights==0;
weights=weights+normrnd(0,.12,1,length(weights));
weights(weights<0)=0;
weights(ind)=0;
weights=weights/sum(weights);

% weights=unifrnd(0,1,1,n);
% weights=weights/sum(weights);
    