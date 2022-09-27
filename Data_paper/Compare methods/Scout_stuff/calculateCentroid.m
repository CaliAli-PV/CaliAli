function centroid=calculateCentroid(A_individual,height,width)
if ~exist('width','var')
    width=height(2);
    height=height(1);
end
A_individual=reshape(A_individual,[height,width]);
centroid=zeros(1,2);
temp=find(A_individual>0);
for l=1:length(temp)
    [i,j]=ind2sub([height,width],temp(l));
     centroid=centroid+[j,i]*A_individual(i,j);
    
end

centroid=centroid/sum(sum(A_individual));

