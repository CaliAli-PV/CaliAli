function [minM,img12]=estimate_min_correlation(O,bounds,plotme)

%  maxM=estimate_mean_motion_flow(O,4,1);
%  maxM=estimate_mean_motion_flow(O3,4,1);


[d1,d2,~] = size(O);

if (bounds==1)
    bound1=round(d1/10);
    bound2=round(d2/10);
else
    bound1=0;
    bound2=0;
end


Ob=O(bound1+1:end-bound1,bound2+1:end-bound2,:);


b=nchoosek(1:size(Ob,3),2);
M=zeros(size(Ob,3),size(Ob,3));

for i=1:size(b,1)
    f1=Ob(:,:,b(i,1));
    f2=Ob(:,:,b(i,2));
    motion=get_cosine(double(f1(:)'),double(f2(:))');
    M(b(i,1),b(i,2))=mean(sqrt((real(motion(:)).^2)+(imag(motion(:)).^2)));
end
M=M+M'+diag(ones(1,size(M,1)));

minM=min(M,[],'all');


[~,I] = min(M(:));
[x,y]=ind2sub(size(M),I);
img1=Ob(:,:,x);
img2=Ob(:,:,y);
img12 = imfuse(histeq(img1),histeq(img2),'ColorChannels',[1 2 0]);
if (plotme==1)
    figure;imshow(img12)
end

