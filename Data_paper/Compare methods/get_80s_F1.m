
for i=1:size(M,1)
X(i,:)=[table2array(M.(3){i,1}(80,1))];
end

X=reshape(X,7,[]);