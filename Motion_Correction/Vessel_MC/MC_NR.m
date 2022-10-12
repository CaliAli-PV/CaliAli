function out=MC_NR(in,win)
% out=MC_NR(v);
if ~exist('win','var')
    win=20;
end
%% Get Vesselness-filtered image
VF=in2VF(in);
%% Calculatign Shifts
D=get_alignments(VF,win);

%% Applying Shifts

v = squeeze(num2cell(in,[1 2]));
fprintf('Applying shift...\n')
b2 = ProgressBar(size(v,1), ...
    'IsParallel', true, ...
    'UpdateRate', 1,...
    'WorkerDirectory', pwd());
b2.setup([], [], []);
parfor i=1:size(v,1)
    out(:,:,i) = imwarp(v{i},D(:,:,:,i));
    updateParallel([], pwd);
end
b2.release();
%  implay(cat(1,in,out));
end

function VF=in2VF(in)
VF=vesselness_PV(in,1,0.5:0.5:2);
VF=v2uint8(VF);
end

function D=get_alignments(VF,win)

%% distribute video in 20-frames batches
fprintf('Distributing video in small batches...\n')
x=round(linspace(1,size(VF,3),size(VF,3)/win));
x(1)=0;
for i=1:size(x,2)-1
    G{i}=VF(:,:,x(i)+1:x(i+1));
end
%%================================ Intra-batch registration
fprintf('Running Intra-batch Registration...\n')
b2 = ProgressBar(size(x,2)-1, ...
    'IsParallel', true, ...
    'UpdateRate', 1,...
    'WorkerDirectory', pwd());
b2.setup([], [], []);
parfor k=1:size(x,2)-1
    [O{k},D{k}]=batch_register(G{k})
    updateParallel([], pwd);
end
b2.release();

%%================================ Inter-batch registration
for i=1:size(G,2)
    M(:,:,i)=median(O{i},3);
end


Dm=zeros(size(M,1),size(M,2),2,size(M,4));
opt = struct('niter',25, 'sigma_fluid',2,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);


fprintf('Running Inter-batch Registration...\n')
b2 = ProgressBar(size(M,3), ...
    'IsParallel', true, ...
    'UpdateRate', 1,...
    'WorkerDirectory', pwd());
b2.setup([], [], []);
parfor i=2:size(M,3)
    [~,Dm(:,:,:,i)] =register(M(:,:,1),M(:,:,i),opt);
    updateParallel([], pwd);
end
b2.release();


%%================================ Shifts redistribution
disp('Distributing shifts...')
Dm=Dm-mean(Dm,4);
%
parfor i=1:size(M,3)
    oM(:,:,i) = imwarp(M(:,:,i),Dm(:,:,:,i));
end

for i=1:size(D,2)
    D{i}=D{i}+Dm(:,:,:,i);
end
D=cat(4,D{:});

end

function [O,D]=batch_register(in)
T=in(:,:,1);
O(:,:,1)=T;
D=zeros(size(T,1),size(T,2),2,size(T,3));

opt = struct('niter',5, 'sigma_fluid',1,...
    'sigma_diffusion',10, 'sigma_i',0.1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);

for i=2:size(in,3)
    [O(:,:,i),D(:,:,:,i)] =register(T,in(:,:,i),opt);
end

end