function [A,C_raw,C,S,Ymean,Cn_update] = int_temp_batch(neuron)


%%
d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.CaliAli_options.cnmf.gSig;
n_enhanced=neuron.CaliAli_options.preprocessing.neuron_enhance;
gSiz=gSig*4;
F=get_batch_size(neuron);
fn=[0,cumsum(F)];
for i=progress(1:size(fn,2)-1)
    try
        Y = neuron.load_patch_data([],[fn(i)+1,fn(i+1)]);
    catch
        debugCaliAli(neuron)
        return

    end
    Ymean{i}=double(median(Y,3));

    if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
    Y(isnan(Y)) = 0;    % remove nan values

    %% preprocessing data
    % create a spatial filter for removing background
    if n_enhanced==0
        if neuron.options.center_psf
            psf = fspecial('gaussian', ceil(gSiz+1), gSig);
            ind_nonzero = (psf(:)>=max(psf(:,1)));
            psf = psf-mean(psf(ind_nonzero));
            psf(~ind_nonzero) = 0;
        else
            psf = fspecial('gaussian', round(gSiz), gSig);
        end
    else
        psf = [];
    end

    % filter the data
    if isempty(psf)
        % no filtering
        HY = Y;
    else
        HY = imfilter(reshape(single(Y), d1,d2,[]), psf, 'replicate');
    end

    HY = reshape(single(HY), d1*d2, []);

    %% PV Remove media in each session

    HY = bsxfun(@minus, HY, median(HY, 2));

    %% Get PNR and CN PV
    if ~isempty(neuron.CaliAli_options.inter_session_alignment.Cn)
        Cn=neuron.CaliAli_options.inter_session_alignment.Cn;
        PNR=neuron.CaliAli_options.inter_session_alignment.PNR;
    else
        [~,Cn,PNR]=get_PNR_coor_greedy_PV(reshape(HY,d1,d2,[]),gSig,[],[],n_enhanced);
    end
    %%
    % screen seeding pixels as center of the neuron

    Mask=neuron.CaliAli_options.cnmf.seed_mask;

    if isempty(Mask)
        Mask=true(d1,d2);
    end

    %% Intialize variables
    seed_all=get_seeds(neuron);
    A=[];
    C=[];
    C_raw=[];
    S=[];
    Cn_update(:,:,1)=Cn;
    while true
        % fprintf('%2d seed remaining. \n', length(seed_all));
        seed=get_far_neighbors(seed_all,neuron);
        % [row,col] = ind2sub([d1,d2],seed_all);
        %close all;imagesc(Cn);hold on;
        % plot(col,row,'.r');drawnow;

        seed_all(ismember(seed_all,seed))=[];
        Mask(seed)=0;

        [Y_box,HY_box,ind_nhood,center,sz]=get_mini_videos(Y,HY,seed,neuron);
        if isempty(Y_box)
            break
        end
        [a,c_raw]=estimate_components(Y_box,HY_box,center,sz,neuron,size(Y,2));
        if neuron.options.deconv_flag
        [c,s]=deconv_PV(c_raw,neuron.CaliAli_options.cnmf.deconv_options);
        else
            c=c_raw;
            s=c_raw;
        end
        %% Filter a
        af=a;
        if n_enhanced==0
            parfor k=1:size(a,2)
                if ~isempty(a{k})
                    temp=imfilter(reshape(a{k}, sz{k}(1),sz{k}(2)), psf, 'replicate');
                    af{1,k}=temp(:);
                else
                    af{1,k}=[];
                end
            end
        end
        a=expand_A(a,ind_nhood,d1*d2);
        af=expand_A(af,ind_nhood,d1*d2);
        af(af<0)=0;

        %% update video;
        if isa(Y,'uint8')
            Y=Y-uint8(a*c);
        else
            Y=Y-uint16(a*c);
        end

        HY=HY-single(af*c);
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

kill=sum(C,2)==0;
C(kill,:)=[];
C_raw(kill,:)=[];
S(kill,:)=[];
ix=true(size(S_T{1},1),1);
ix(kill)=false;
C_T=cellfun(@(x) x(ix,:),C_T,'UniformOutput',false);
A_T=cellfun(@(x) x(:,ix,:),A_T,'UniformOutput',false);

weights=cellfun(@(x) max(x,[],2),C_T,'UniformOutput',false);
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
