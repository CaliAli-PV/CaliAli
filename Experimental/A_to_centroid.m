function coor=A_to_centroid(A);

d1=size(A,1);
d2=size(A,2);

for i=1:size(A,3)
    parfor k=1:size(A,4)
        a=A(:,:,i,k);
        w1=mean(a,2);
        w1=w1/sum(w1);
        w2=mean(a,1);
        w2=w2/sum(w2);
        ix1=round(sum((1:d1).*w1'));
        ix2=round(sum((1:d2).*w2));
        % a=a*0;
        % a(ix1,ix2)=1;
        % A(:,:,i,k)=imgaussfilt(a,1);
        coor(i,:,k)=[ix2,ix1];
    end
end

end
