function out=get_BV_NR_score(P,k)
if ~exist('k','var')
k=3;
end
v=P.(size(P,2))(1,:).(k){1,1};
% neuron=mat2gray(squeeze(P.(size(P,2))(1,:).(5){1,1}(:,:,1,:)));
% W=mat2gray(imgaussfilt(neuron,15)).^0.5;
% v=mat2gray(v.*W);
[d1,d2,~]=size(v);
rng(123);%% For reproducibility
seeds=randi(10000,1,100);
parfor i=1:100
    rng(seeds(i));
    [dM]=Add_NRmotion_reg(v);
    vv=reshape(dM,d1*d2,[]);
    S(i,:)=1-pdist(vv','correlation');
end

vv=reshape(v,d1*d2,[]);
o=1-pdist(vv','correlation');

out=min((o-mean(S))./std(S));
