function thr=get_distance_thr_cellReg(footprints)

T1=footprints{1, 1};
T2=footprints{1, 2};


for i=1:size(T1,1)
    A=squeeze(T1(i,:,:));
    props = regionprops(true(size(A)), A, 'WeightedCentroid');  
    coor1(i,:)=props.WeightedCentroid;
end
D1=squareform(pdist(coor1));
D1(logical(diag(ones(1,size(D1,1)))))=nan;
for i=1:size(T2,1)
    A=squeeze(T2(i,:,:));
    props = regionprops(true(size(A)), A, 'WeightedCentroid');  
    coor2(i,:)=props.WeightedCentroid;
end
D2=squareform(pdist(coor2));
D2(logical(diag(ones(1,size(D2,1)))))=nan;

D1=sort(D1,2);
D2=sort(D2,2);

c=[D1(:,3);D2(:,3)];
 
thr=prctile(c,99);