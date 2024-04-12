function neuron=update_residual_custom_seeds(neuron,seed_all_M)
%%
d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
n_enhanced=neuron.n_enhanced;
gSiz=gSig*4;
fn=[0,cumsum(neuron.options.F)];
for i=progress(1:size(fn,2)-1)
    Y = neuron.load_patch_data([],[fn(i)+1,fn(i+1)]);

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
    Cn=neuron.Cnr;
    PNR=neuron.PNRr;

    %%
    % screen seeding pixels as center of the neuron
    Mask=neuron.options.Mask;

    %% Intialize variables
    A=[];
    C=[];
    C_raw=[];
    S=[];    
    seed_all=seed_all_M;
    while true
        % fprintf('%2d seed remaining. \n', length(seed_all));
        seed=get_far_neighbors(seed_all,d1,d2,gSiz*1.5,Cn,PNR);
        % [row,col] = ind2sub([d1,d2],seed);
        % plot(col,row,'.r');drawnow;

        seed_all(ismember(seed_all,seed))=[];
        Mask(seed)=0;

        [Y_box,HY_box,ind_nhood,center,sz]=get_mini_videos(Y,HY,seed,d1,d2,gSiz);
        if isempty(Y_box)
            break
        end
        [a,c_raw]=estimate_components(Y_box,HY_box,center,sz,neuron.options.spatial_constraints,size(Y,2));
        [c,s]=deconv_PV(c_raw,neuron.options.deconv_options);
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
I=cellfun(@(x) mean(x,2),S_T,'UniformOutput',false);
I=cat(2,I{:});
I=I./sum(I,2);
A=A_T{1, 1}*0;  
for i=1:size(I,2)
    A=A+A_T{1, i}.*I(:,i)';
end

A=mean(cat(3,A_T{:}),3);
C=cat(2,C_T{:});
C_raw=cat(2,C_raw_T{:});
S=cat(2,S_T{:});

kill=sum(S,2)==0;
A(:,kill)=[];
C(kill,:)=[];
C_raw(kill,:)=[];
S(kill,:)=[];

neuron.A=cat(2,neuron.A,A);
neuron.C=cat(1,neuron.C,C);
neuron.C_raw=cat(1,neuron.C_raw,C_raw);
neuron.S=cat(1,neuron.S,S);
neuron.ids=cat(2,neuron.ids,max(neuron.ids):max(neuron.ids)+size(A,2));

end