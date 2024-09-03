function [results, center, Cn, PNR]=greedyROI_endoscope_CaliAli_original(Y,Caliali_options,Mask,neuron_options)
% [tmp_results, tmp_center, tmp_Cn, tmp_PNR, ~] = greedyROI_endoscope_PV(Ypatch, K, tmp_options, [], tmp_save_avi);

%%
[d1,d2,F]=size(Y);
n_enhanced=Caliali_options.n_enhanced;


if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
Y(isnan(Y)) = 0;    % remove nan values


%% preprocessing data
% create a spatial filter for removing background
if n_enhanced==0
        psf = fspecial('gaussian', ceil(gSiz+1), gSig);
        ind_nonzero = (psf(:)>=max(psf(:,1)));
        psf = psf-mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
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

%% Set params
gSig=Caliali_options.gSig;
n_enhanced=Caliali_options.n_enhanced;
gSiz=gSig*4;
%% Get PNR and CN PV

[~,Cn,PNR]=get_PNR_coor_greedy_PV(reshape(HY,d1,d2,[]),gSig,[],[],n_enhanced);
% Cn=Cn./Caliali_options.Cn_scale;
%%
% screen seeding pixels as center of the neuron


if isempty(Mask)
    Mask=true(d1,d2);
end

%% Intialize variables
min_corr=neuron_options.min_corr;

seed_all=get_seeds(Cn,PNR,gSig,min_corr,neuron_options.min_pnr,Mask);
A=[];
C=[];
C_raw=[];
S=[];
KP=[];
while true
    % fprintf('%2d seed remaining. \n', length(seed_all));
    seed=get_far_neighbors(seed_all,d1,d2,gSiz*1.5,Cn,PNR);
    % [row,col] = ind2sub([d1,d2],seed_all);
    %close all;imagesc(Cn);hold on;
    % plot(col,row,'.r');drawnow;

    seed_all(ismember(seed_all,seed))=[];
    Mask(seed)=0;

    [Y_box,HY_box,ind_nhood,center,sz]=get_mini_videos(Y,HY,seed,d1,d2,gSiz);
    if isempty(Y_box)
        break
    end
    [a,c_raw]=estimate_components(Y_box,HY_box,center,sz,neuron_options.spatial_constraints,size(Y,2));
    [c,s,kp]=deconv_PV(c_raw,neuron_options.deconv_options);
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
        Y=Y-a*c;
    end

    HY=HY-single(af*c);
    A=cat(2,A,a);
    C=cat(1,C,c);
    C_raw=cat(1,C_raw,c_raw);
    S=cat(1,S,s);
    KP=cat(1,KP,kp);

    if isempty(seed_all)
        break
    end
end

kill=sum(S,2)==0;
C(kill,:)=[];
C_raw(kill,:)=[];
S(kill,:)=[];


%% export the results
results.Ain = sparse(A);
results.Cin = C;
results.Cin_raw = C_raw;
if neuron_options.deconv_flag
    results.Sin = S;
    results.kernel_pars=KP;
end
% Cin(Cin<0) = 0;
end
