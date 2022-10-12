function neuron=update_residual(neuron)

[A,C_raw,C,S] = update_residual_inside(neuron);

neuron.A=[neuron.A,sparse(A)];
neuron.C_raw=[neuron.C_raw;C_raw];
neuron.C=[neuron.C;C];
neuron.S=[neuron.S;sparse(S)];

K = size(A, 2);
k_ids = neuron.P.k_ids;
neuron.ids = [neuron.ids, k_ids+(1:K)];
neuron.tags = [neuron.tags;zeros(K,1, 'like', uint16(0))];
neuron.P.k_ids = K+k_ids;


end




function [A,C_raw,C,S] = update_residual_inside(neuron);
n_enhanced=neuron.n_enhanced;
Y = neuron.load_patch_data();

d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
gSiz=gSig*4;

if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
Y(isnan(Y)) = 0;    % remove nan values
T = size(Y, 2);

%% substract neurons

if isa(Y,'uint8')
    Y=Y-uint8(full(neuron.A)*neuron.C);
else
    Y=Y-uint16(full(neuron.A)*neuron.C);
end



if isempty(neuron.options.F)
    F=T;
else
    F=neuron.options.F;
end

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
if size(F,1)>1
    t=0;
    for i=1:size(F,1)
        HY(:,t+1:t+F(i)) = HY(:,t+1:t+F(i))-median(HY(:,t+1:t+F(i)),2);
        t=F(i);
    end
else
    HY = bsxfun(@minus, HY, median(HY, 2));
end
if size(HY,2)>10000
    Sn=GetSn_fast(HY,1000,10,d1,d2);
else
    Sn=GetSn(HY);
end

[~,Cn,PNR]=get_PNR_coor_greedy_PV(reshape(HY, d1,d2,[]),0,F,Sn,n_enhanced);
Cn=mat2gray(Cn);
%%
if ~isempty(neuron.Mask)
    Mask=neuron.Mask;
else
 Mask=logical(1-Cn*0);
end

%% avoid updating seed close to detected components

% get neurons centers
Coor = neuron.get_contours(0.8);

Coor=round(cell2mat(cellfun(@(x) mean(x,2)',Coor,'UniformOutput',false)));
Coor(sum(Coor,2)==0,:)=[];
ind = sub2ind([neuron.options.d1,neuron.options.d2],Coor(:,2),Coor(:,1));

Z=zeros(neuron.options.d1,neuron.options.d2);

Z(ind)=1;

h = fspecial('disk',neuron.options.gSig);

T = imfilter(Z,h,'replicate')>0;

Mask=Mask&~T;

%% Intialize variables
A=[];
C=[];
C_raw=[];
S=[];
seed_all=get_seeds(Cn,PNR,gSig,neuron.options.min_corr,neuron.options.min_pnr,Mask);
%% plot
[row,col] = ind2sub([d1,d2],seed_all);
imagesc(Cn);hold on;drawnow;

while true
    fprintf('%2d seed remaining. \n', length(seed_all));
    seed=get_far_neighbors(seed_all,d1,d2,gSiz*1.5,Cn,PNR);
    [row,col] = ind2sub([d1,d2],seed);
    plot(col,row,'.r');drawnow;
    seed_all(ismember(seed_all,seed))=[];
    Mask(seed)=0;
    [Y_box,HY_box,ind_nhood,center,sz]=get_mini_videos(Y,HY,seed,d1,d2,gSiz);
    if length(Y_box)==0
        break
    end
    [a,c_raw]=estimate_components(Y_box,HY_box,center,sz,neuron.options.spatial_constraints);
    [c,s]=deconv_PV(c_raw,neuron.options.deconv_options);
    %% Filter a
    af=a;
    if n_enhanced==0
        parfor k=1:size(a,2)
            temp=imfilter(reshape(a{k}, sz{k}(1),sz{k}(2)), psf, 'replicate');
            af{1,k}=temp(:);
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

end