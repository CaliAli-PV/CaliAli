function [Aout,bA,C]=create_neuron_data(d1,d2,min_dist,Nneu,F,ses,plotme,spike_prob,create_mask)

if ~exist('plotme','var')
plotme=0;
end
if create_mask
BW=create_heart_mask(d1,d2);
else
 BW=ones(d1,d2);
end
[y, x] = find(BW);
[X,Y]=get_random_points(x,y,min_dist,Nneu,plotme);

[d1,d2]=size(BW);
Aout=[];
bA=[];
n_sz=2.5;  %neuron size
load('A.mat');

for i=1:length(X)
Z=zeros(d1,d2);
Z(Y(i),X(i))=1;
Aout(:,:,i)=conv2(Z, A(:,:,randi(size(A,3))), 'same');
bA(:,:,i)=imgaussfilt(Aout(:,:,i),10,'FilterSize',d2+1);
end


Aout=Aout./max(Aout,[],'all');
bA=bA./max(bA,[],'all');
if plotme
 figure;imshow(max(Aout,[],3));
 figure;imshow(max(bA,[],3));
end

P=lognrnd(spike_prob(1),spike_prob(2),Nneu,1);
C=[];
for i=1:ses
c=create_random_spike(length(X),F,P);
C=cat(2,c,C);
end

% C=C.*(1+randn(length(X),1).*0.2);
% 



