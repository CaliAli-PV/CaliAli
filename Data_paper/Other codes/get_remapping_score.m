function [rs,p]=get_remapping_score(C,F)

tim=1:length(F);
S=separate_sessions(C,F,0);
D=mean_sessions(S);

ac=D./max(D,[],2);
rh=[];pval=[];
for i=1:size(ac,1)

 [rh(i),pval(i)] = corr(tim',ac(i,:)');
end

p=mean(pval<0.05);

sig=ac(pval<0.05,:);

[~,I]=sort(sig(:,end)-sig(:,1));
% imagesc(sig(I,:));

for i=1:size(sig,2)
    rs(i)=( (1-pdist([sig(:,i),sig(:,1)]','cosine'))-(1-pdist([sig(:,i),sig(:,end)]','cosine')) )    / ( (1-pdist([sig(:,i),sig(:,1)]','cosine'))+(1-pdist([sig(:,i),sig(:,end)]','cosine')) )  ;
end