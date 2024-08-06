function [out,I]=compare_points_reference(varargin)
% [out,I]=compare_points_reference(SS,CA,NP);
ix=[];
for i=1:length(varargin)
    ix=[ix;ones(size(varargin{1, i},4),1)*(i-1)];
end

A_all=[];
for i=1:length(varargin)
    A_all=cat(4,A_all,varargin{1, i});
end

A=squeeze(A_all);
A=reshape(A,size(A,1)*size(A,2),[]);
A=A./max(A,1);
%% convert into cosine space
D=pdist(A','cosine');
MS=mdscale(D,3,'criterion','strain');

%% calculate mahalanobis distance in cosine space
Ref=MS(ix==0,:);
S=cov(Ref);
invS=pinv(S);
M1=mean(Ref);
dist=zeros(size(A,2),1);
for i=1:size(A,2)
dx=MS(i,:)-M1;
dist(i)=sqrt(dx*invS*dx');
end

T=table(log(dist),categorical(ix),'VariableNames',{'D','IX'});
mdl=fitlm(T,'D~IX');
mdl.Coefficients(2:end,end)

out=[];
for i=0:max(ix)
    out=catpad(2,out,log10(dist(ix==i)));
end





