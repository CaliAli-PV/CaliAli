function [Shifts_total,C]=get_shifts_sim(in)
%  [Shifts,C]=get_shifts_sim(X);
in=v2uint8(in);

%% get vesselness image
X1=in(:,:,:,1);
T=cat(4,repmat(X1,[1,1,1,2]),repmat(X1.*0,[1,1,1,2]));
[S,W_loc,W_all]=get_shift_in(T);


W_all=W_all./sum(W_all,2);
% Weight shifts by overall similarity
for i=1:numel(S);
    S{i}=S{i}.*W_all(i);
end

Shifts=get_sum_S(S);
%% get Cn image
X2=in(:,:,:,2);
parfor i=1:size(X2,3)
    X2(:,:,i)=imwarp(squeeze(X2(:,:,i)),Shifts{i},'FillValues',nan);
end


T=repmat(X2,[1,1,1,2]);
[S2,W_loc2,W_all2]=get_shift_in(T);




% Weight shifts by local similarity
% for i=1:size(S2,1)
%     w=mat2gray(cat(3,W_loc2{i,:}));
%     w=w./sum(w,3);
%     w(isnan(w))=0;
%     t=cat(3,S2{i,:}).*w;
%     S2(i,:)=squeeze(num2cell(t,[1,2,4]))';
% end
Shifts2=get_mean_S(S2);

Shifts_total=cat(4,Shifts{:})+cat(4,Shifts2{:});

parfor i=1:size(X1,3)
    VB(:,:,i)=imwarp(squeeze(in(:,:,i,1)),Shifts_total(:,:,:,i),'FillValues',nan);
    Cn(:,:,i)=imwarp(squeeze(in(:,:,i,2)),Shifts_total(:,:,:,i),'FillValues',nan);
end

P=reshape(VB,size(VB,1)*size(VB,2),[]);

C=min(1-pdist(P','cosine'));


end

%% Get shifts

function Shifts=get_sum_S(S)

for i=1:size(S,1)  
    Shifts{i}=squeeze(sum(cat(3,S{i,:}),3));
end
end

function Shifts=get_mean_S(S)

for i=1:size(S,1)  
    Shifts{i}=squeeze(mean(cat(3,S{i,:}),3));
end
end



function [S,W_loc,W_all]=get_shift_in(X)

parfor i=1:size(X,3)
    T=squeeze(X(:,:,i,:));
    [t1,t2,t3]=link_func(T,X);
    S(i,:)=t1;
    W_loc(i,:)=t2;
    W_all(i,:)=t3;
end

end

function [t1,t2,t3]=link_func(T,X)

for k=1:size(X,3)
    [temp,t2{k},t3(k)]=demon_in(T,squeeze(X(:,:,k,:)));
    t1{k}=temp*-1;
end
end

%% get shifts and, local and global similarities.
function [S,W_loc,W_global]=demon_in(M1,M2)
opt = struct('niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);
% implay(cat(3,M1(:,:,1),M2(:,:,1)));

[t1,t2,S]=MR_Log_demon(M1,M2,opt);
t1=t1(:,:,1);
t2=t2(:,:,1);
% implay(cat(3,t1,t2));
% get local sim
[~,local_sim] = ssim(t1,t2,'Exponents',[0 0 1]);
M=mat2gray(t1.*t2);
local_sim(local_sim<0)=0;
W_loc=imgaussian(local_sim.*M,opt.sigma_diffusion);
W_global=1-get_cosine(double(t1(:)'),double(t2(:)'));
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
