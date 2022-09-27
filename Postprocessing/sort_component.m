function [out,I]=sort_component(A_com,ix)

A=squeeze(A_com);
A=reshape(A,size(A,1)*size(A,2),[]);
A=A./max(A,1);
%% convert into cosine space
D=pdist(A','cosine');
MS=mdscale(D,10,'criterion','strain');

%% calculate mahalanobis distance in cosine space
Ref=MS(ix,:);
S=cov(Ref);
invS=pinv(S);
M1=mean(Ref);
dist=zeros(size(A,2),1);
for i=1:size(A,2)
dx=MS(i,:)-M1;
dist(i)=sqrt(dx*invS*dx');
end

[dist,I]=sort(dist,'ascend');

out=A_com(:,:,:,I);
