function out=get_blood_vessel_corr_score(v)

v=reshape(v,size(v,1)*size(v,2),[]);
v=1-squareform(pdist(v','correlation'));
d2=size(v,2);
t=linspace(0.1,1,100);
for i=1:100
    G = graph(v>t(i));
    A= conncomp(G);
    s(i)=length(unique(A));
    if s(i)>1
        break
    end
end
out=t(i);




