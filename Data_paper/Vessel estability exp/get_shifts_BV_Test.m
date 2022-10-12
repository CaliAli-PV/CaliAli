function [Shifts,C]=get_shifts_BV_Test(X)
X=v2uint8(X);
d3=size(X,3);
% [D,ans] = imregdemons(Vf(:,:,i),Vf(:,:,i-1));
parfor i=1:d3
    M1=squeeze(X(:,:,i,:));
    Shifts(:,:,:,i)=get_shift_in(M1,X);
end


 parfor i=1:size(X,3)
     P(:,:,i)=imwarp(squeeze(X(:,:,i,1)),Shifts(:,:,:,i),'FillValues',nan);
 end

 P=reshape(P,size(P,1)*size(P,2),[]);

 C=min(1-pdist(P','correlation')); 


end

function out=get_shift_in(M1,X)

opt = struct('niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);
[d1,d2,~,~]=size(X);

t_shifts=zeros(d1,d2,2,size(X,3));
for k=1:size(X,3)
    M2=squeeze(X(:,:,k,:));
    [t1,t2,t_shifts(:,:,:,k)]=MR_Log_demon(M1,M2,opt);
end
out=sum(-t_shifts,4,'omitnan');
end


