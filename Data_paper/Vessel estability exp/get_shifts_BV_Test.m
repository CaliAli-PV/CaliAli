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
    [~,temp] = ssim(t1(:,:,1),t2(:,:,1),'Exponents',[0 0 1]);
    M=mat2gray(t1(:,:,1).*t2(:,:,1));
    t1v=t1(:,:,end);
    t2v=t2(:,:,end);
    sw(k)=1-pdist([double(t1v(:)');double(t2v(:)')],'correlation');
    temp(temp<0)=0;
    W(:,:,k)=temp.*M;
end
sw=sw./sum(sw);
for i=1:size(W,3)
    W(:,:,i) = imgaussian(W(:,:,i),opt.sigma_diffusion.*3).*sw(i);  % smooth weights.
end

W=W./sum(W,3);
for i=1:size(W,3)
    W(:,:,i) = regionfill(W(:,:,i),isnan(W(:,:,i)));
end
W=reshape(W,[d1,d2,1,size(X,3)]);
W=cat(3,W,W);
out=sum(-t_shifts.*W,4,'omitnan');

end

function I = imgaussian(I,sigma)
if sigma==0; return; end; % no smoothing

% Create Gaussian kernel
radius = ceil(3*sigma);
[x,y]  = ndgrid(-radius:radius,-radius:radius); % kernel coordinates
h      = exp(-(x.^2 + y.^2)/(2*sigma^2));
h      = h / sum(h(:));

% Filter image
I = imfilter(I,h);
end
