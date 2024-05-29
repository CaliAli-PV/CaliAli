function [T,Mask]=remove_borders(in,nanval)

[d1,d2,d3]=size(in);
T=zeros(d1+2,d2+2,d3,class(in))*nan;
T(2:d1+1,2:d2+1,:)=in;
clear in
if ~exist('nanval','var')
N=sum(isnan(T),3)>0;
else
  T(isnan(T))=nanval; 
 N=max(T==nanval,[],3);      
end
N=1-N;
[~,~, ~, M] = FindLargestRectangles(N);

Mask=M(2:end-1,2:end-1);
f1=max(sum(M,1));
f2=max(sum(M,2));

T=reshape(T,(d1+2)*(d2+2),[]);
M=reshape(M,(d1+2)*(d2+2),1);
T(~M,:)=[];
T=reshape(T,f1,f2,[]);
end


