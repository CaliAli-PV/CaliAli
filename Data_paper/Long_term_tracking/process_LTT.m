function process_LTT(in,F);

A=logical([1,0,0,1,1,0,0,1,1,0,1,0,0,1,1,0,0,1,1,0]);
ses=2:2:20;
ac=[];
for j=1:3
    ac_t=[];
    for s=1:length(ses)
        k=0;
        M=[];
        for i=1:ses(s)
            M(:,i)=max(in.(j)(s,1).c(:,k+1:k+F(i)),[],2);
            k=k+F(i);
        end

        Con{s,j}=[(1-pdist(zscore(M(:,A(1:ses(s))))','correlation')),...
            (1-pdist(zscore(M(:,A(1:ses(s))))','correlation'))]';
        ac_t(s,:)=[mean(prod(M>7,2)),flip(bootci(1000,@(x) mean(prod(x>7,2)),M))'];
    end
    ac=cat(2,ac,ac_t);
end

end
