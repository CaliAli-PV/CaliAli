function out=MC_NR_not_used_testing(in,win,opt)
% out=MC_NR_not_used_testing(V);
if ~exist('win', 'var')
    win = min(opt.sf*6, size(in, 3));
elseif isempty(win)
    win = min(opt.sf*6, size(in, 3));
end
%% Get Vesselness-filtered image
% VF=in2VF(in);
[X]=get_BS_neuron_enhance(in,opt);
%% Calculatign Shifts
out=get_alignments(X+1,in,win);
M=max(isnan(out),[],3);

if isa(in,'uint16')
out=v2uint16(out);
elseif isa(in,'uint8')
out=v2uint8(out);
end

out=out+1;

[d1,d2,d3]=size(out);
out=reshape(out,d1*d2,d3)+1;

M=M(:);

out(M,:)=0;
out=reshape(out,d1,d2,d3);



%  implay(cat(1,in,out));
end


function out=get_alignments(X,in,win)

%% distribute video in 20-frames batches
disp('Distributing video in small batches...')
x=round(linspace(1,size(X,4),size(X,4)/win));
x(1)=0;
if length(x)==1
x=[0,size(X,4)];
end

[ms, ~] = get_trans_score(mat2gray(squeeze(X(:,:,1,:))), [], 1, 1, 0.01);
ms=[ms,0];
for i=1:size(x,2)-1
    MS{i}=ms(x(i)+1:x(i+1));
    G{i}=X(:,:,:,x(i)+1:x(i+1));
end

plotme=0;

opt{1,1}  = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',6, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme,'scale',0.5);
opt{2,1} = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',6, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme,'scale',1);
opt{3,1} = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',6, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme,'scale',1);

%%================================ Intra-batch registration
parfor k=1:size(x,2)-1
    [~,ix]=min(MS{k});
    T=G{k}(:,:,:,ix);
    [O{k},D{k},Va{k}]=batch_register(G{k},V{k},opt,T);
end

%%================================ Inter-batch registration
for i=1:size(G,2)
    M(:,:,:,i)=uint8(imsharpen(mean(O{i},4)));
end

% ppm = ParforProgressbar(size(M,4)-1,'title', 'Inter-batch Registration');
Dm=zeros(size(M,1),size(M,2),2,size(M,4));
%  [~,s2,Dm(:,:,:,i)] =MR_Log_demon(Ma,imhistmatch(M(:,:,:,i),Ma),opt);
temp(:,:,:,1)=M(:,:,:,1);
Ma=temp;




for i=progress(2:size(M,4), 'Title', 'Inter-batch registration')
    [~,temp(:,:,:,i),Dm(:,:,:,i)] =MR_Log_demon(Ma,M(:,:,:,i),opt);
    Ma=imsharpen(temp(:,:,:,i));
end
% delete(ppm);

%%================================ Shifts redistribution
disp('Distributing shifts...')
Dm=Dm-mean(Dm,4);
%
parfor i=1:size(M,4)
    oM(:,:,:,i) = imwarp(M(:,:,:,i),Dm(:,:,:,i));
end

for i=1:size(D,2)
    D{i}=D{i}+Dm(:,:,:,i);
end
D=cat(4,D{:});

    % a=uint8(mean(Va{i},3));
    neu=uint8(max(squeeze(O{i}(:,:,1,:)),[],3));
    bv=uint8(mean(squeeze(O{i}(:,:,3,:)),3));
    P(:,:,:,i)=cat(3,neu,bv,bv);
end

R=P(:,:,:,1);
temp=R;
for i=progress(2:size(P,4), 'Title', 'Inter-batch registration')
    [~,temp(:,:,:,i),Dm(:,:,:,i)] =MR_Log_demon(R,P(:,:,:,i),opt);
    bv=mean(squeeze(temp(:,:,1,:)),3);
    neu=max(squeeze(temp(:,:,3,:)),[],3);
    R=cat(3,neu,bv,bv);
end

% for i=progress(2:size(P,4), 'Title', 'Applying shifts')
%     temp=Va{1, i};
%     for k=1:size(temp,3)
%          temp(:,:,k) = imsharpen(imwarp(temp(:,:,k),Dm(:,:,:,i),"FillValues",nan));
%     end
%     Va{1, i}=temp;
% end
out=cat(3,Va{:});
end

function [O,D]=batch_register(in,MS,opt)
[~,I]=min(MS);
T=in(:,:,:,I);
O(:,:,:,1)=T;
D=zeros(size(T,1),size(T,2),2,size(in,4));

for i=1:size(in,4)
    [~,O(:,:,:,i),D(:,:,:,i)] =MR_Log_demon(T,in(:,:,:,i),opt);
end

end

function t=get_score(V);
opt = struct('stop_criterium',0.001,'imagepad',1.2,'niter',5, 'sigma_fluid',1,...
    'sigma_diffusion',5, 'sigma_i',1,...
    'sigma_x',2, 'do_display',0, 'do_plotenergy',0);

[d1,d2,d3,d4]=size(V);
C=squeeze(mat2cell(V,d1,d2,d3,ones(1,d4)));
C(2:end,2)=C(1:end-1,1);
parfor i=2:d4
    K=C(i,:);
    im1=uint8(mean(K{1,2},3));
    im2=uint8(mean(K{1,1},3));
    [X1,X2,D]=MR_Log_demon(im1,im2,opt);
    %     sz=1;
    %     [~,temp]=ssim(im1,im2,'Exponents',[0 0 1],'Radius',sz,'RegularizationConstants',[0,0,0]);
    ou(:,:,i)=sqrt(D(:,:,:,1).^2+D(:,:,:,2).^2);
    %    ou(:,:,i-1)=1-imgaussfilt(temp,3);
end
t=squeeze(max(max(ou)));
t(1)=t(2);
end






