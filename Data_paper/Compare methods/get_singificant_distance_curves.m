function [p,d]=get_singificant_distance_curves(x1,x2)


if ~exist('alpha','var')
    alpha = 0.05;
end


d=max(abs(mean(x1,2)-mean(x2,2)));

xs=[x1,x2];
n=size(x1,2);
parfor i=1:10000
    I=zeros(1,size(xs,2));
    p = randperm(size(xs,2),n)
    I(p)=1;
    I=logical(I);
  
    sx1=xs(:,I);
    sx2=xs(:,~I);
    ds(i)=max(abs(mean(sx1,2)-mean(sx2,2)));
end

ds=sort(ds,2);

 
p=(sum(ds>d,2)+1)/10001;
