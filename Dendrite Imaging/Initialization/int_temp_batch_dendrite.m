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
    Mask=neuron.options.Mask;
    if isempty(Mask)
        Mask=true(d1,d2);
    end

    %% Intialize variables
    seed_all=get_seeds(neuron);
    A=[];
    C=[];
    C_raw=[];
    S=[];
    while true
        seed=get_far_neighbors(seed_all,neuron);
        seed_all(ismember(seed_all,seed))=[];
        Mask(seed)=0;
        [Y_box,ind_nhood,center,sz]=get_mini_videos_dendrite(Y,seed,neuron);
        if isempty(Y_box)
            break
        end
        try
        [a,c_raw]=estimate_components_dendrite(Y_box,center,sz,size(Y,2),neuron.CaliAli_opt);
        catch
            dummy=1
        end
        [c,s]=deconv_PV(c_raw,neuron.options.deconv_options);
 
        %% Filter a
        a=expand_A(a,ind_nhood,d1*d2);

        signal=single(a*c);
        signal(isnan(signal))=0;
        %% update video;
        Y=Y-signal;

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

