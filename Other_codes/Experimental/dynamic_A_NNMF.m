function [A,N,kill]=dynamic_A_NNMF(A,weights,d)
% d=[obj.options.d1,obj.options.d2];
weights=mat2cell(weights,ones(size(weights,1),1),size(weights,2));
A=permute(reshape(A,d(1),d(2),size(A,2),size(A,3)),[3,1,2,4]);
A=num2cell(A,[2,3,4]);
A=cellfun(@(x) squeeze(x),A,'UniformOutput',false);
[A,N,kill]=dynamic_A_NNMF_in(A,weights,d);
A=permute(cat(3,A{:}),[1,3,2]);
end

function [A,N,kill]=dynamic_A_NNMF_in(A,weights,d)
kill=false(size(A,1),1);
rngSeed = parallel.pool.Constant(1);
parfor i=1:size(A,1)
    a=reshape(A{i},d(1)*d(2),[]);
    [A{i},kill(i),sa(i),N(i),W{i},H{i},R(i)]=run_nmfa(a,d,rngSeed);
end
end



function [a,kill,n,N,W,H,R]=run_nmfa(a,d,rngSeed)
localSeed = rngSeed.Value;
% Seed the RNG for each worker using a unique combination
rng(localSeed , 'combRecursive');
R=rand(1);
if sum(a,"all")~=0
    a=a./sum(a);
    a(isnan(a))=0;
    n = NumberOfAssemblies(a);
    if n==0
        n=1;
    end
    warning('off', 'all');
    [W,H] = nnmf(a,n);
    k=(sum(W,1)==0)'|sum(H.^2./sum(H.^2,2)>0.8,2)>0; %% "Exclude inactive
    % components or components where 80% of the energy is concentrated
    % within a single session."
    W(:,k)=[];
    H(k,:)=[];
    if isempty(W)
        [W,H] = nnmf(a,1,"algorithm","mult",'replicates',10);
    end
    H=H./sum(H,1);
    H=fillmissing(H','knn',5)';
    W=W./max(W,[],1);
    N=size(W,2);
    Nc=reshape(W*H,d(1),d(2),[]);
    Nc = medfilt3(Nc,[3 3 3]);
    for j=1:size(Nc,3)
        Nc(:,:,j)=connectivity_constraint(Nc(:,:,j));
    end
    Nc=mat2gray(Nc)*4;
    a=reshape(Nc,d(1)*d(2),[]);
    kill=false;
else
    kill=true;
    a=reshape(mat2gray(a)*4,d(1)*d(2),[]);
end
end