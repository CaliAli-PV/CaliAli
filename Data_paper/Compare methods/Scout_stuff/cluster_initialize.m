function [idx,num_cluster]=cluster_initialize(num_cluster,session_ids,similarity,chain_prob);
if num_cluster==1
    idx=ones(length(session_ids),1);
    return
end
idx=zeros(length(session_ids),1);
% for k=1:max(session_ids)
%     ind=session_ids==k;
%     clust=randperm(num_cluster,sum(ind));
%     idx(ind)=clust;
% end
%Most dissimilar values
for k=1:max(session_ids)
    try
        similarity(session_ids==k,session_ids==k)=nan;
    end
end
M=max(similarity,[],'all','linear','omitnan');
if ~isnan(M)
    
    I=find(similarity==M);
    I=I(randi(length(I)));
    [a,b]=ind2sub(size(similarity),I);
    idx(a)=1;
    idx(b)=2;
elseif length(idx)>1
    idx(1)=1;
    idx(2)=2;
else
    idx(1)=1;
end
% ind=find(similarity>.2);
% if length(ind)==0
%  ind=find(isnan(similarity));
% end
% ind=ind(randi(length(ind)));
% [a,b]=ind2sub(size(similarity),ind);
% idx(a)=1;
% idx(b)=2;


similarity(:,b)=nan;
similarity(:,a)=nan;
base=[a,b];
while sum(~isnan(similarity),'all')>0
    for indl=1:length(base)
        dup_sess(indl)=~(length(session_ids(idx==indl))==length(unique(session_ids(idx==indl))));
    end 
    
    mins=ones(1,length(base));
    index=zeros(size(mins));
    for j=1:length(mins)
        ind=find(ismember(session_ids,session_ids(idx==j)));
        similarity(base(j),ind)=nan;
        [mins(j),index(j)]=min(similarity(base(j),:),[],'omitnan');
    end
    [M,I]=min(mins,[],'omitnan');
    if M>=1-chain_prob||isempty(M)||sum(isnan(mins))==length(mins)
        [a,b]=find(~isnan(similarity));
        while ismember(b(1),base)
            b=b(2:end);
        end
        base(end+1)=b(1);
        similarity(:,b(1))=nan;
        idx(b(1))=max(idx)+1;
    elseif sum(mins==0)>1
        I=find(mins==0);
        I1=I(randi(length(I)));
        I=find(similarity(base(I1),:)==0);
        I2=I(randi(length(I)));
        idx(I2)=idx(base(I1));
        similarity(:,I2)=nan;
    else
        idx(index(I))=I;
        similarity(:,index(I))=nan;
        similarity(base(I),session_ids==session_ids(index(I)))=nan;
    end
end

num_cluster=max(idx);
ind=find(idx==0);
idx(ind)=num_cluster+1:num_cluster+length(ind);
num_cluster=max(idx);
    
idx=reshape(idx,length(idx),1);
    