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
ppm = ParforProgressbar(size(v,1),'title', 'Applying Shifts');
parfor i=1:size(v,1)
out(:,:,i) = imwarp(v{i},D(:,:,:,i));
ppm.increment();
end
delete(ppm);
%  implay(cat(1,in,out));
end

function VF=in2VF(in)
VF=vesselness_PV(in,1,0.5:0.5:2);
VF=v2uint8(VF);
end

function D=get_alignments(VF,win)

%% distribute video in 20-frames batches
disp('Distributing video in small batches...')
x=round(linspace(1,size(VF,3),size(VF,3)/win));
x(1)=0;
for i=1:size(x,2)-1    
  G{i}=VF(:,:,x(i)+1:x(i+1)); 
end
%%================================ Intra-batch registration
ppm = ParforProgressbar(size(x,2)-1,'title', 'Intra-batch Registration');
parfor k=1:size(x,2)-1   
[O{k},D{k}]=batch_register(G{k})
ppm.increment();
end
delete(ppm);

%%================================ Inter-batch registration
for i=1:size(G,2)    
  M(:,:,i)=median(O{i},3);
end

ppm = ParforProgressbar(size(M,3)-1,'title', 'Inter-batch Registration');
Dm=zeros(size(M,1),size(M,2),2,size(M,4));
opt = struct('niter',25, 'sigma_fluid',2,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);


parfor i=2:size(M,3)
    [~,Dm(:,:,:,i)] =register(M(:,:,1),M(:,:,i),opt);
    ppm.increment();
end
delete(ppm);


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



