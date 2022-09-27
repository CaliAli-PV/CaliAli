function [Shifts,P,Scor]=get_shifts_alignment(P)
Mb=v2uint8(cell2mat(P{1,1}));
Vf=v2uint8(cell2mat(P{1,2}));
X=v2uint8(cell2mat(P{1,5}));
[d1,d2,d3]=size(Vf);
Shifts=zeros(d1,d2,2,1);
% [D,ans] = imregdemons(Vf(:,:,i),Vf(:,:,i-1));
parfor i=1:d3
    elem=1:d3;
%     elem(i)=[];
    t_shifts(:,:,:,i)=get_shift_in(i,Vf,X,Mb);
end

for k=1:size(P,2)
    temp=cell2mat(P{1,k});
    parfor i=1:size(Vf,3)
        temp(:,:,i)=imwarp(temp(:,:,i),t_shifts(:,:,:,i),'FillValues',nan);
    end

    P{1,k}={temp};
end
Shifts=Shifts+t_shifts;


for k=1:size(P,2)
    P.(k){1,1}=remove_borders(P.(k){1,1});
end
%%%%%%%%%


pre=estimate_min_correlation(X,1,0);
post=estimate_min_correlation(cell2mat(P{1,5}),1,0);
Scor=[pre,post];






end

function out=get_shift_in(elem,Vf,X,Mb)

 M1=cat(3,X(:,:,elem),X(:,:,elem),Vf(:,:,elem),Vf(:,:,elem));

opt = struct('niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);
[d1,d2,d3]=size(Vf);

t_shifts=zeros(d1,d2,2,d3);
for k=1:d3
    M2=cat(3,X(:,:,k),X(:,:,k),Vf(:,:,k),Vf(:,:,k));
    [t1,t2,t_shifts(:,:,:,k)]=MR_Log_demon(M1,M2,opt);
    loc_c=get_local_corr_Vf(cat(3,double(t1(:,:,1)),double(t2(:,:,1))),double(cat(3,Mb(:,:,elem),Mb(:,:,k))));
    t1v=t1(:,:,end);
    t2v=t2(:,:,end);
    glob_c(k)= 1-pdist([double(t1v(:)');double(t2v(:)')],'correlation');
    W(:,:,k)=loc_c;
end
glob_c=glob_c./sum(glob_c);
for i=1:size(W,3)
    W(:,:,i) = imgaussian(W(:,:,i),opt.sigma_diffusion*3).*glob_c(i);  % smooth weights.
end 

W=W./sum(W,3);
for i=1:size(W,3)
    W(:,:,i) = regionfill(W(:,:,i),isnan(W(:,:,i)));
end 
W=reshape(W,[d1,d2,1,length(elem)]);
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
