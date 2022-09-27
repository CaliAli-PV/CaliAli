function kill = remove_sparse_PV(A,d1,d2)

[d,K]=size(A);

A_new = mat2cell(A, d, ones(1,K));
se = strel('disk', 2);
kill=zeros(K,1);
parfor m=1:K
    ai = reshape(full(A_new{m}), d1, d2);

kill(m) = sum(imopen(ai, se),'all')==0;
end
kill=logical(kill);
end