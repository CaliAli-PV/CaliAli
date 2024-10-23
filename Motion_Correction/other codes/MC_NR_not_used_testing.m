function V=MC_NR_not_used_testing(V,BV,win,opt)
% out=MC_NR_not_used_testing(V);
if ~exist('win', 'var')
    win = [20,60];
elseif isempty(win)
    win = [20,60];
end
%% Get Vesselness-filtered image
% VF=in2VF(in);
[X]=get_BS_neuron_enhance(V,BV,opt);
%% Calculatign Shifts
V=NR_motion_correction_parallel(X,V,win);
%  implay(cat(1,in,out));
end


function V=NR_motion_correction_parallel(X,V,win)

%% Dfine options
plotme=0;
opt{1,1}  = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',8, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme,'scale',0.5);
opt{2,1} = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',8, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme,'scale',0.8);
opt{3,1} = struct('stop_criterium',0.001,'imagepad',1.2,'niter',10, 'sigma_fluid',1,...
    'sigma_diffusion',6, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme,'scale',1);


[ms1, ~] = get_trans_score(mat2gray(squeeze(X(:,:,1,:))), [], 1, 1, 0.3);

[MS,G,V]=distribute(X,V,ms1,win);
[V,G]=MC_in(MS,G,V,opt);
X=cat(4,G{:});
V=cat(3,V{:});
[ms2, ~] = get_trans_score(mat2gray(squeeze(X(:,:,1,:))), [], 1, 1, 0.01);
end

function [MS,G,Vc]=distribute(X,V,ms,win)

disp('Distributing video in small batches...')
v=movmedian(ms<prctile(ms,50),50)>0.5;
v(1:win(2):end)=0;
CC = bwlabel(v);

rp=regionprops(logical(CC),'area');
for i=1:max(CC)
    if rp(i).Area<win(1)
        CC(CC==i)=0;
        CC(CC>i)=CC(CC>i)-1;
    end
end
CC(CC==0)=nan;
CC=fillmissing(CC, 'nearest');

%% distribute video in batches
for i=1:max(CC)
    MS{i}=ms(CC==i);
    G{i}=X(:,:,:,CC==i);
    Vc{i}=V(:,:,CC==i);
end
end

function [V,G]=MC_in(MS,G,V,opt)
%%================================ Intra-batch registration
parfor k=1:length(MS)
    [~,ix]=min(MS{k});
    T=G{k}(:,:,:,ix);
    [G{k},~,V{k}]=batch_register(G{k},V{k},opt,T);
end

end

function [O,D,V]=batch_register(G,V,opt,T)
O(:,:,:,1)=T;
D=zeros(size(T,1),size(T,2),2,size(G,4));
for i=1:size(G,4)
    [~,O(:,:,:,i),D(:,:,:,i)] =MR_Log_demon(T,G(:,:,:,i),opt);
end

for i=1:size(G,4)
    V(:,:,i) = imwarp(V(:,:,i),D(:,:,:,i),'FillValues',0);
end

end




