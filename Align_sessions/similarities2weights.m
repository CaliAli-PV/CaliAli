function out=similarities2weights(loc_w)

for i=1:size(loc_w,2)
    loc_w{i,i}=loc_w{1, 2}*0;
end
for k=1:size(loc_w,1)
    x=cat(3,loc_w{k,:});
    for i=1:size(x,3)
        x(:,:,i) = adapthisteq(x(:,:,i));
    end
    x=mat2gray(x);
    x(x<0.1)=0;
    for i=1:size(x,3)
        x(:,:,i)=imgaussfilt(x(:,:,i),1, 'FilterSize',31);
    end

    b=1+x;
    b=b-max(x,[],3);
    b=mat2gray(b);

    for i=1:size(b,3)
        b(:,:,i)=mat2gray(imgaussfilt(b(:,:,i),15, 'FilterSize',91));
    end
   for i=1:size(b,3)
        b(:,:,i) = adapthisteq(b(:,:,i));
    end

    b(:,:,k)=0;
    [d1,d2,d3]=size(b);
    out(k,:) = squeeze(mat2cell(b./sum(b,3), d1, d2, ones(1, d3)))';
end
