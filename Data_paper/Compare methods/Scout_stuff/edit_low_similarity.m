function prob=edit_low_similarity(aligned,prob,min_prob)
threshold=0.7;
unique_vals=unique(aligned(:,1));
for k=1:length(unique_vals)
    ind=find(aligned(:,1)==unique_vals(k));
    if max(prob(ind))<threshold
        prob(ind)=nan;
    end
end

unique_vals=unique(aligned(:,2));
for k=1:length(unique_vals)
    ind=find(aligned(:,2)==unique_vals(k));
    if max(prob(ind))<threshold
        prob(ind)=nan;
    end
end
