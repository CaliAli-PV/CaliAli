function out=Align_A_batch(neuron)
%% Scale components
A=neuron.A_batch;
A=reshape(A,neuron.options.d1,neuron.options.d2,size(A,2),size(A,3));
A=squeeze(max(A,[],3));
A=mat2gray(A);

%% Align by translation


%% non rigid_alignment
tic
parfor i=1:size(A,3)
    [D(:,:,:,i),mp(:,:,i)]=imregdemons(A(:,:,i), A(:,:,1), [500 400 200], 'AccumulatedFieldSmoothing', 1.3,'DisplayWaitbar',false);
end
toc;

out=reshape(neuron.A_batch,neuron.options.d1,neuron.options.d2,size(neuron.A_batch,2),[]);
[d1, d2, d3, d4] = size(out);
out=squeeze(mat2cell(out, d1, d2, d3, ones(1, d4)));
out=apply_shifts_in(out,D);
out=cellfun(@(x) reshape(x,d1*d2,d3,[]),out,'UniformOutput',false);
out=cat(3,out{:});
end




