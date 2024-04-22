function weights=get_weights_spatial(obj)

F=get_batch_size(obj,0);
batch=[0,cumsum(F)];
div=length(batch)-1;
for i=1:div
    weights(:,i)=mean(obj.S(:,batch(i)+1:batch(i+1)),2);
end

weights=weights.^2;
weights=weights./sum(weights,2);