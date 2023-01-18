function [Sc,X]=get_opto_responding(S,opto);
wb=20;
wa=20;

[d1,d2]=size(S);
onsets=find(diff(opto)>0.5);
k=0;
pre=[];
post=[];
for i=1:length(onsets)
    if (onsets(i)-wb>0 && onsets(i)+wa<=d2)
        k=k+1;
    pre(:,:,k)=full(S(:,onsets(i)-wb+1:onsets(i)));
    post(:,:,k)=full(S(:,onsets(i)+1:onsets(i)+wa));
    end
end

X=[mean(pre,3),mean(post,3)];

X=(X-mean(mean(pre,3),2))./std(mean(pre,3),[],2);

Sc=mean(X(:,21:end),2);

% 
% P2=squeeze(mean(post,2));
% Bl=squeeze(mean(pre,2));
% 
% Sc=(mean(P2,2)-mean(Bl,2))./std(Bl,[],2);
% Sc(isnan(Sc))=0;
















