function [Shifts,P,Mask]=get_shifts_alignment(P,opt,only_neurons)

if ~exist("only_neurons",'var')
    only_neurons=false;
end


if ~opt.do_alignment
    [d1,d2,d3]=size(P.(1){1,1});
    Mask=true(d1,d2);
    Shifts=zeros(d1,d2,2,d3);
    return
end


%% pre allocate data for parallel computing
[Proj,b,P]=pre_allocate_projections(P,opt,only_neurons);

%% Get transformation matrix, and local and global weights.
[T,locW,globW]=get_matrices(Proj,b);
globW=globW./sum(globW);
%% weigths to 4d
locW=reshape(locW,[size(locW,1),size(locW,2),1,size(locW,3)]);
locW=cat(3,locW,locW);
for i=1:length(globW)
    W(:,:,:,i)=locW(:,:,:,i).*globW(i);
end
W=W./sum(W,4);

%% Calculate weighted transformations
for i=1:size(T,1)
    t=cat(4,T{i,:});
    t=t.*W;
    Shifts(:,:,:,i)=sum(t,4);
end

Shifts(isnan(Shifts))=0;
Shifts=Shifts-mean(Shifts,4);
%% apply shifts to projections
for k=1:size(P,2)
    temp=double(cell2mat(P{1,k}));
    parfor i=1:size(Shifts,4)
        temp(:,:,i)=imwarp(temp(:,:,i),Shifts(:,:,:,i),'FillValues',nan);
    end
    P{1,k}={temp};
end

%% remove black borders
Mask=1-max(isnan(P.(k){1,1}),[],3);
[~,Mask]=remove_borders(Mask,0);
for k=1:size(P,2)
    temp=P.(k){1,1};
    P.(k){1,1}=remove_borders(temp);
end

end

function [Proj,b,P]=pre_allocate_projections(P,opt,only_neurons)
Mb=v2uint8(cell2mat(P{1,1})); % Mean frame
Vf=v2uint8(cell2mat(P{1,2})); % Blood vessels


Cn=cell2mat(P{1,3});
PNR=cell2mat(P{1,4});
Cn=v2uint8(mat2gray(PNR).*mat2gray(Cn).^2);
for i=1:size(Cn,3)
    Cn(:,:,i)=adapthisteq(Cn(:,:,i));
end

if ~contains(opt.projections,'BV')||only_neurons
    Vf=Cn;
end

if ~contains(opt.projections,'neuron')
    Cn=Vf;
end

for i=1:size(Cn,3)
    X(:,:,i)=mat2gray(max(cat(3,Vf(:,:,i),medfilt2(Cn(:,:,i))),[],3));
end
X=v2uint8(X);
P.(5){1,1}=mat2gray(X);
Proj_t=permute(cat(4,Mb,Cn,X,Vf,Vf),[1,2,4,3]);
[d1,d2,d3,d4]=size(Proj_t);  % data dimensions
Proj_t=squeeze(mat2cell(Proj_t,d1,d2,d3,ones(1,d4))); % split data for parallel computing

%% Calculate transformation array
% Prealocate images for parallel computing.

b=nchoosek(1:d4,2);
for i=1:size(b,1)
    Proj{i,1}=Proj_t{b(i,1)};
    Proj{i,2}=Proj_t{b(i,2)};
end
clear Proj_t;
end

%% NESTED FUNCTIONS

function [T,loc_c,glob_c]=get_matrices(Proj,b)
% pre allocate variables
T=cell(size(b,1),1);
loc_c=cell(size(b,1),1);
glob_c=zeros(size(b,1),1);

Tb=cell(size(b,1),1);
loc_cb=cell(size(b,1),1);
glob_cb=zeros(size(b,1),1);

parfor i=1:size(b,1)
    img=Proj(i,:);
    % get transformations:
    [t_T,t_loc_c,t_glob_c,t_Tb,t_loc_cb,t_glob_cb,fwa,bwa]=get_transformations(img{1},img{2});
    % backward and forward variables need to be stored separately.
    FWA{i}=fwa;
    BWA{i}=bwa;
    T{i}=t_T;
    loc_c{i}=t_loc_c;
    glob_c(i,1)=t_glob_c;
    Tb{i}=t_Tb;
    loc_cb{i}=t_loc_cb;
    glob_cb(i,1)=t_glob_cb;
end

T=[T,Tb];clear Tb;
loc_c=[loc_c,loc_cb];clear loc_cb;
glob_c=[glob_c,glob_cb];clear glob_cb;
[T,loc_c,glob_c]=arrange_matrix(T,loc_c,glob_c);
end

function [T,LocW,globW]=arrange_matrix(T_t,loc_c_t,glob_c_t)

n=round(max(roots([1 -1 -2*size(T_t,1)]))); % session number
T=cell(n);
loc_w=cell(n);
glob_w=zeros(n,1);

b=nchoosek(1:n,2);
for i=1:size(b,1)
    T{b(i,1),b(i,2)}=T_t{i,1};
    T{b(i,2),b(i,1)}=T_t{i,2};
    loc_w{b(i,1),b(i,2)}=loc_c_t{i,1};
    loc_w{b(i,2),b(i,1)}=loc_c_t{i,2};
    glob_w(b(i,1),b(i,2))=glob_c_t(i,1);
    glob_w(b(i,2),b(i,1))=glob_c_t(i,2);
end
% Replace diagonal elements and standarize weights.
for i=1:n
    T{i,i}=T{1, 2}*0;
    LocW(:,:,i)=mean(cat(3,loc_w{i,:}),3);
    temp=glob_w(i,:);
    temp(i)=[];
    globW(i)=mean(temp);
end
globW=globW./sum(globW);
% LocW=LocW./sum(LocW,3);
X=LocW./sum(LocW,3);
for i=1:size(X,3)
    X(:,:,i) = imgaussfilt(X(:,:,i),8, 'FilterSize',91);
end
LocW=mat2gray(X)./sum(mat2gray(X),3);

% for i=1:size(LocW,3)
%     LocW(:,:,i)=medfilt2(LocW(:,:,i));
% end
if size(LocW,3)==2
    LocW=LocW*0+0.5;
end

end

function [T,loc_c,glob_c,Tb,loc_cb,glob_cb,fwa,bwa]=get_transformations(M1,M2)
plotme=0;
opt{1,1}  = struct('stop_criterium',0.001,'imagepad',1.5,'niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',3, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme);
opt{2,1} = struct('stop_criterium',0.001,'imagepad',1.5,'niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',4, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme);
opt{3,1} = struct('stop_criterium',0.001,'imagepad',1.5,'niter',100, 'sigma_fluid',3,...
    'sigma_diffusion',3, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme);
opt{4,1} = struct('stop_criterium',0.001,'imagepad',1.5,'niter',20, 'sigma_fluid',3,...
    'sigma_diffusion',3, 'sigma_i',1,...
    'sigma_x',2, 'do_display',plotme, 'do_plotenergy',plotme);


Mb=M1(:,:,1); % get mean frame (used to calculate vignetting)
M1(:,:,1)=[]; % The mean fram is NOT used to align videos, therefor removed.
M2(:,:,1)=[];

%%====================================================================
%{
Unfortunatly optical-flow based registration is not inverse consistent.
Therefore we need to calculate forward and backward registration. 
%}

%% GET FORWARD REGISTRATION
% Calculate alignments
[im1,im2,T,tS,im,e]=MR_Log_demon(M1,M2,opt);
fwa=cat(4,im1(:,:,1:3),im2(:,:,1:3));
% [im1,im2,T,~,IM,E]=MR_Log_demon(M1,M2,opt);
% Calculate local similarity
loc_c=get_local_corr_Vf(cat(3,double(im1(:,:,2)),double(im2(:,:,2))),Mb);
% loc_c=mat2gray(imgaussfilt(loc_c.*mat2gray(im2(:,:,2)),5));
% loc_c=double(im2(:,:,2)).*double(im1(:,:,2));
% Calculate global similarity
t1v=im1(:,:,2); % get the BV image
t2v=im2(:,:,2); % get the BV image
glob_c= 1-pdist([double(t1v(:)');double(t2v(:)')],'correlation');
T=squeeze(-T);

%% GET BACKWARD REGISTRATION
% Calculate alignments
[im1,im2,Tb]=MR_Log_demon(M2,M1,opt);
bwa=cat(4,im1(:,:,1:3),im2(:,:,1:3));
% Calculate local similarity
loc_cb=get_local_corr_Vf(cat(3,double(im1(:,:,2)),double(im2(:,:,2))),Mb);
% loc_cb=mat2gray(imgaussfilt(loc_cb.*mat2gray(im2(:,:,2)),5));
% loc_cb=double(im2(:,:,2)).*double(im1(:,:,2));
% Calculate global similarity
t1v=im1(:,:,end); % get the BV image
t2v=im2(:,:,end); % get the BV image
glob_cb= 1-pdist([double(t1v(:)');double(t2v(:)')],'correlation');
Tb=squeeze(-Tb);
end

