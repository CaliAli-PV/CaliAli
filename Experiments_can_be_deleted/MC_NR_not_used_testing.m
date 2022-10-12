function out=MC_NR_not_used_testing(in,win)
% out=MC_NR_not_used_testing(V);
if ~exist('win','var')
    win=60;
end

%% Get Vesselness-filtered image
% VF=in2VF(in);
[X]=get_BS_neuron_enhance(in);
%% Calculatign Shifts
D=get_alignments(X,win);





%% Applying Shifts
v = squeeze(num2cell(in,[1 2]));
b = ProgressBar(size(v,1), ...
    'IsParallel', true, ...
    'UpdateRate', 1,...
    'WorkerDirectory', pwd(), ...
    'Title', 'Applying shifts' ...
    );
    b.setup([], [], []);

parfor i=1:size(v,1)
out(:,:,i) = imsharpen(imwarp(v{i},D(:,:,:,i)));
updateParallel([], pwd);
end
b.release();

%  implay(cat(1,in,out));
end


function D=get_alignments(X,win)

%% distribute video in 20-frames batches
disp('Distributing video in small batches...')
x=round(linspace(1,size(X,4),size(X,4)/win));
x(1)=0;
ms=get_score(X);
for i=1:size(x,2)-1  
   MS{i}=ms(x(i)+1:x(i+1));
  G{i}=X(:,:,:,x(i)+1:x(i+1)); 
end

%%================================ Intra-batch registration
b = ProgressBar(size(x,2)-1, ...
    'IsParallel', true, ...
    'UpdateRate', 1,...
    'WorkerDirectory', pwd(), ...
    'Title', 'Intra-batch registration' ...
    );
    b.setup(1, [], []);
parfor k=1:size(x,2)-1   
[O{k},D{k}]=batch_register(G{k},MS{k})
updateParallel([], pwd);
end
b.release();

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
    [~,temp(:,:,:,i),Dm(:,:,:,i)] =MR_Log_demon_MC_batch(Ma,M(:,:,:,i));
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

end

function [O,D]=batch_register(in,MS)
[~,I]=min(MS);
T=in(:,:,:,I);
O(:,:,:,1)=T;
D=zeros(size(T,1),size(T,2),2,size(in,4));

for i=1:size(in,4)
    [~,O(:,:,:,i),D(:,:,:,i)] =MR_Log_demon_MC_batch(T,in(:,:,:,i));
end

end

function t=get_score(V);
opt{1} = struct('niter',5, 'sigma_fluid',1,...
    'sigma_diffusion',5, 'sigma_i',1,...
    'sigma_x',2, 'do_display',0, 'do_plotenergy',0);

[d1,d2,d3,d4]=size(V);
C=squeeze(mat2cell(V,d1,d2,d3,ones(1,d4)));
C(2:end,2)=C(1:end-1,1);
b = ProgressBar(d4-1, ...
    'IsParallel', true, ...
    'UpdateRate', 10,...
    'WorkerDirectory', pwd(), ...
    'Title', 'calculating motion score' ...
    );
    b.setup(1, [], []);
parfor i=2:d4
   K=C(i,:);
   im1=uint8(mean(K{1,2},3));
   im2=uint8(mean(K{1,1},3));
    [X1,X2,D]=MR_Log_demon_MC_batch(im1,im2,opt);
%     sz=1;
%     [~,temp]=ssim(im1,im2,'Exponents',[0 0 1],'Radius',sz,'RegularizationConstants',[0,0,0]);
    ou(:,:,i)=sqrt(D(:,:,:,1).^2+D(:,:,:,2).^2);
%    ou(:,:,i-1)=1-imgaussfilt(temp,3);
updateParallel([], pwd);
end
b.release();
t=squeeze(max(max(ou)));
t(1)=t(2);
end






