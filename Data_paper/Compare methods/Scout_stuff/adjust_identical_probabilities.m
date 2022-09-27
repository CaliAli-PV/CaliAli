function probabilities=adjust_identical_probabilities(probabilities,aligned,distance_metrics,similarity_pref)
probabilities=reshape(probabilities,[],1);
probabilities1=probabilities;
distance_metrics=reshape(distance_metrics,length(probabilities),[]);
indices=unique(aligned(~isnan(probabilities),1));
indices=setdiff(indices,nan);
for k=1:length(indices)
    ind=find(aligned(:,1)==indices(k)&~isnan(probabilities));
    ind1=intersect(ind,find(probabilities>=max(probabilities(ind))-.001));
    if length(ind1)>1
        comp=aligned(ind1,2);
        vals=mean(distance_metrics(ind1,:),2);
        if isequal(similarity_pref,'high')
            [~,I]=sort(vals,'descend');
        else
            [~,I]=sort(vals,'ascend');
        end
        probabilities(ind1(I))=probabilities(ind1(I))-.025*((1:length(ind1))-1)';
        ind=setdiff(ind,ind1);
        probabilities(ind)=probabilities(ind)-.025*length(ind1);
    end
end
indices=unique(aligned(~isnan(probabilities),2));
indices=setdiff(indices,nan);
for k=1:length(indices)
    ind=find(aligned(:,2)==indices(k));
    ind1=intersect(ind,find(probabilities>=max(probabilities(ind))-.001));
    if length(ind1)>1
        comp=aligned(ind1,1);
        vals=mean(distance_metrics(ind1,:),2);
        if isequal(similarity_pref,'high')
            [~,I]=sort(vals,'descend');
        else
            [~,I]=sort(vals,'ascend');
        end
        probabilities(ind1(I))=probabilities(ind1(I))-.025*((1:length(ind1))-1)';
        ind=setdiff(ind,ind1);
        probabilities(ind)=probabilities(ind)-.025*length(ind1);
    end
end


%Reverse the order
indices=unique(aligned(~isnan(probabilities1),2));
indices=setdiff(indices,nan);
for k=1:length(indices)
    ind=find(aligned(:,2)==indices(k));
    ind1=intersect(ind,find(probabilities1>=max(probabilities1(ind))-.001));
    if length(ind1)>1
        comp=aligned(ind1,1);
        vals=mean(distance_metrics(ind1,:),2);
        if isequal(similarity_pref,'high')
            [~,I]=sort(vals,'descend');
        else
            [~,I]=sort(vals,'ascend');
        end
        probabilities1(ind1(I))=probabilities1(ind1(I))-.025*((1:length(ind1))-1)';
        ind=setdiff(ind,ind1);
        probabilities1(ind)=probabilities1(ind)-.025*length(ind1);
    end
end

indices=unique(aligned(~isnan(probabilities1),1));
indices=setdiff(indices,nan);
for k=1:length(indices)
    ind=find(aligned(:,1)==indices(k)&~isnan(probabilities1));
    ind1=intersect(ind,find(probabilities1>=max(probabilities1(ind))-.001));
    if length(ind1)>1
        comp=aligned(ind1,2);
        vals=mean(distance_metrics(ind1,:),2);
        if isequal(similarity_pref,'high')
            [~,I]=sort(vals,'descend');
        else
            [~,I]=sort(vals,'ascend');
        end
        probabilities1(ind1(I))=probabilities1(ind1(I))-.025*((1:length(ind1))-1)';
        ind=setdiff(ind,ind1);
        probabilities1(ind)=probabilities1(ind)-.025*length(ind1);
    end
end
probabilities=(probabilities+probabilities1)/2;
probabilities(probabilities<0)=0;