function [Aout,bA,C,S,LFP]=create_neuron_data(opt)
%% Create Mask
if opt.create_mask
BW=create_heart_mask(opt.d);
else
 BW=ones(opt.d);
end
%% Create random spatial
[Aout,bA]=create_spatial(BW,opt);

%% Adjust spike probability and kinetics to the sf
spike_prob=opt.spike_prob;
spike_prob(1)=log(exp(spike_prob(1))/opt.sf);
spike_prob(2)=spike_prob(2)/opt.sf;
invtRise=opt.invtRise;
invtRise(1)=log(exp(invtRise(1))/opt.sf);
invtDecay=opt.invtDecay;
invtDecay(1)=log(exp(invtDecay(1))/opt.sf);

%% create spike probability distribution
P=lognrnd(spike_prob(1),spike_prob(2),size(Aout,3),1);
C=[];
LFP=[];
S=[];
for i=1:opt.ses
[c,lfp,s]=create_random_spike(size(Aout,3),opt.F,opt.sf,P,invtRise,invtDecay,opt.LFP);
C=[C,c];
LFP=[LFP,lfp];
S=[S,s];
end

% C=C.*(1+randn(length(X),1).*0.2);
% 

end


function [Aout,bA]=create_spatial(BW,opt)
[y, x] = find(BW);
[X,Y]=get_random_points(x,y,opt.min_dist,opt.Nneu,opt.plotme);

Aout=[];
bA=[];
load('A.mat');

for i=1:length(X)
Z=zeros(opt.d);
Z(Y(i),X(i))=1;
Aout(:,:,i)=conv2(Z, A(:,:,randi(size(A,3))), 'same');
bA(:,:,i)=imgaussfilt(Aout(:,:,i),10,'FilterSize',opt.d(2)+1);
end

Aout=Aout./max(Aout,[],'all');
bA=bA./max(bA,[],'all');
if opt.plotme
 figure;imshow(max(Aout,[],3));
 figure;imshow(max(bA,[],3));
end
end

