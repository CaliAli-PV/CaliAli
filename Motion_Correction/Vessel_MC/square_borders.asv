function [T,Mask]=square_borders(in,nanval)

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

[~,~, ~, M] = FindLargestRectangles(1-N);

M=M(2:end-1,2:end-1);
Mask=M;
T([1,end],:,:)=[];T(:,[1,end],:)=[];

T=reshape(T,(d1)*(d2),[]);
M=reshape(M,(d1)*(d2),1);
T(~M,:)=0;
T=reshape(T,d1,d2,[]);