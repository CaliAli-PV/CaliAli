function A_=Ato2d(obj)
A=obj.A_batch;
if size(A,3)>1
    weights=get_weights_spatial(obj);
    for i=1:size(weights,1)
        A_(:,i)=sum(squeeze(A(:,i,1:end)).*weights(i,:),2);
    end
else
    A_=A;
end
end