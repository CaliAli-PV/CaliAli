function [X]=get_mean_trace(S,opto)
wb=20;
wa=30;

[d1,d2]=size(S);
onsets=find(diff(opto)>0.5);
k=0;
pre=[];
post=[];
for i=1:length(onsets)
    if (onsets(i)-wb>0 && onsets(i)+wa<=d2)
        k=k+1;
        bl(:,:,k)=full(S(:,onsets(i)-wb+1:onsets(i)));
        tr=full(S(:,onsets(i)-wb+1:onsets(i)+wa))-mean(bl(:,:,k),2);
        X(:,:,k)=tr;
    end
end

X=mean(X,3);

X=X./std(squeeze(mean(bl,2)),[],2);
X(isnan(X))=0;