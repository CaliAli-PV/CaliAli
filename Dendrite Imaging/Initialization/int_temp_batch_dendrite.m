function [A,C_raw,C,S,Ymean] = int_temp_batch_dendrite(neuron)


%%
d1=neuron.options.d1;
d2=neuron.options.d2;
F=get_batch_size(neuron);
fn=[0,cumsum(F)];
for i=progress(1:size(fn,2)-1)
    Y = neuron.load_patch_data([],[fn(i)+1,fn(i+1)]);
    Ymean{i}=double(median(Y,3));
    if ~ismatrix(Y); Y = single(reshape(Y, d1*d2, [])); end % convert the 3D movie to a matrix
    Y(isnan(Y)) = 0;    % remove nan values
    %%
    % screen seeding pixels as center of the neuron
    if isempty(neuron.CaliAli_options.cnmf.seed_mask)
        neuron.CaliAli_options.cnmf.seed_mask=true(d1,d2);
    end

    %% Intialize variables
    seed_all=get_seed_dendrites(neuron);
    A=[];
    C=[];
    C_raw=[];
    S=[];
    while true
        seed=get_far_neighbors(seed_all,neuron);
        seed_all(ismember(seed_all,seed))=[];
        [Y_box,ind_nhood,center,sz,Cn_in]=get_mini_videos_dendrite(Y,seed,neuron,neuron.CaliAli_options.inter_session_alignment.Cn);
        if isempty(Y_box)
            break
        end

        [a,c_raw]=estimate_components_dendrite(Y_box,center,sz,size(Y,2),neuron.CaliAli_options,Cn_in);

        [c,s]=deconv_PV(c_raw,neuron.CaliAli_options.cnmf.deconv_options);

        %% Filter a

        a=expand_A(a,ind_nhood,d1*d2);

          Y=Y-a*c;


        % Cn=neuron.CaliAli_options.inter_session_alignment.Cn;[row,col] = ind2sub([d1,d2],seed);
        % figure;imagesc(Cn);hold on;plot(col,row,'or');
        % figure;imagesc(mat2gray(reshape(max(a,[],2),d1,d2)));


        A=cat(2,A,a);
        C=cat(1,C,c);
        C_raw=cat(1,C_raw,c_raw);
        S=cat(1,S,s);

        if isempty(seed_all)
            break
        end
    end

    A_T{i}=A;
    C_T{i}=C;
    C_raw_T{i}=C_raw;
    S_T{i}=S;
end
C=cat(2,C_T{:});
C_raw=cat(2,C_raw_T{:});
S=cat(2,S_T{:});

kill=sum(S,2)==0;
C(kill,:)=[];
C_raw(kill,:)=[];
S(kill,:)=[];
ix=true(size(S_T{1},1),1);
ix(kill)=false;
S_T=cellfun(@(x) x(ix,:),S_T,'UniformOutput',false);
A_T=cellfun(@(x) x(:,ix,:),A_T,'UniformOutput',false);

weights=cellfun(@(x) mean(x,2),S_T,'UniformOutput',false);
weights=cat(2,weights{:});
weights=weights.^2;
weights=weights./sum(weights,2);
A=A_T{1, 1}*0;
for i=1:size(weights,2)
    A=A+A_T{1, i}.*weights(:,i)';
end
A=mean(cat(3,A_T{:}),3);
kill=sum(A>0)==0;
A(:,kill)=[];
C(kill,:)=[];
C_raw(kill,:)=[];
S(kill,:)=[];



end

