function s=BL_sim(Mr)

for i=1:size(Mr,1)
    X=Mr{i,1};
    for k=1:2
        Vf(:,:,k)=adapthisteq(vesselness_PV(X(:,:,k),0,(0.6:0.032:0.9).*2.5),'Distribution','exponential');
    end
    s(i)=1-pdist(reshape(Vf,size(X,1)*size(X,2),[])','cosine');
    X=[];
    Vf=[];
end