function labeledImage=spatial2labeledImage(A,d)

labeledImage=zeros(d);
for i=1:size(A,2)
    labeledImage=labeledImage+(reshape(A(:,i),d)>0).*i;
end