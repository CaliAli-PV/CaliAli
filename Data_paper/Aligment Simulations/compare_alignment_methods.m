function [Score,err,dist]=compare_alignment_methods(inp)
%  
[out,Mot,~,~,A]=Simulate_Ca_video_main(inp{:},'translation',0);
Mot=cat(4,Mot{:});

BW=create_heart_mask(220,300);
BW=BW(21:200,21:280,:);


Mot=Mot.*BW;

%% get alignment images;
for i=1:size(out,2)
    fprintf(1, '======================\n');
    in = mat2gray(out{i});
    T=mean(in,3);
    M(:,:,i)=T;
    fprintf(1, 'Obtaining Vesselness image\n');
%     T=T-gsmoothn(T, [0 50], 'Region', 'same');
    Vf(:,:,i)=vesselness_PV(T,0,[1.5,1.58,1.66,1.74,1.82,1.9,1.98,2.06,2.14,2.22]);
    Vf(:,:,i) = adapthisteq(Vf(:,:,i),'Distribution','exponential');
    temp=filter_video(in,2.5);
    fprintf(1, 'Obtaining Filtered image\n');
    Filt(:,:,i)=mat2gray(mean(temp,3));
    fprintf(1, 'Obtaining Correlation image\n');
    det=det_video(in,10);
    [~,Cn(:,:,i),~]=get_PNR_coor_greedy_PV(det,2.5);
end

%% adjust Vf contrast
for i=1:size(Vf,3)
    Cn(:,:,i)=adjust_C(Cn(:,:,i));
%     Vf(:,:,i) = mat2gray(imhistmatch(Vf(:,:,i),Cn(:,:,i),'Method','polynomial'));
end
Cn=mat2gray(Cn);
for i=1:size(Vf,3)
    x(:,:,i)=mat2gray(max(cat(3,Vf(:,:,i),medfilt2(Cn(:,:,i))),[],3));
end

%%
% mean
X=repelem(M,1,1,1,4);
[err(1,1),Score(1,1),dist(:,1)]=get_correction_score_W(X,Mot,A,BW);

% filt
X=repelem(Filt,1,1,1,4);
[err(1,2),Score(1,2),dist(:,2)]=get_correction_score_W(X,Mot,A,BW);

% Cn 
X=repelem(Cn,1,1,1,4);
[err(1,3),Score(1,3),dist(:,3)]=get_correction_score_W(X,Mot,A,BW);

% Vessel image 
% X=repelem(Vf,1,1,1,4);
X=cat(4,repelem(x,1,1,1,2),repelem(Vf,1,1,1,2));
[err(1,4),Score(1,4),dist(:,4)]=get_correction_score_W(X,Mot,A,BW);

% Vessel + Cn

X=cat(4,repelem(Cn,1,1,1,1),repelem(x,1,1,1,1),repelem(Vf,1,1,1,2));
[err(1,5),Score(1,5),dist(:,5)]=get_correction_score_W(X,Mot,A,BW);


end

function out=get_cum(sim)
for i=1:1000
    thr=i/1000;
    out(:,i)=sum(sim>=thr,2)./length(sim)*100;
end
end

function out=filter_video(in,gSig)
gSiz = 4*gSig;
psf = fspecial('gaussian', round(2*gSiz), gSig);
ind_nonzero = (psf(:)>=max(psf(:,1)));
psf = psf-mean(psf(ind_nonzero));
psf(~ind_nonzero) = 0;   % only use pixels within the center disk
out = imfilter(in,psf,'symmetric');
end


function out=det_video(in,sf)
[d1,d2,d3]=size(in);
dt = detrend_PV(sf,reshape(double(in),[d1*d2,d3]));
dt=dt./GetSn(dt);
out=reshape(dt,d1,d2,d3);
end

function out=get_similarity_component(A,D)
a1=A{1, 1};

    a2=A{1, 2};
    for i=1:size(a2,3)
        temp=imwarp(a2(:,:,i),D);
        temp_a1=a1(:,:,i);
        out(i)=1-get_cosine(temp_a1(:)',temp(:)');
    end
end


function [err,score,dist]=get_correction_score_W(X,Mot,A,BW)
% [M_s,~,~,~,~]=get_shifts_warp(M,0,0,2);

D=get_shifts_main(X);
sim=get_similarity_component(A,D);
dist=get_cum(sim);
D=D.*BW;
Mot=squeeze(Mot(:,:,:,2));
score=1-get_cosine(-D(:)',Mot(:)');
err=max(abs(-D(:)-Mot(:)));
end

function Cn=adjust_C(Cn)

N=round(numel(Cn)/size(Cn,3)/100);
[Y,X]=histcounts(Cn(:),N);
X=X(1:end-1);
Y=Y./sum(Y);
Y=movmedian(Y,10);

[~,I]=max(Y(1:round(N/2)));

 Cn=Cn-X(I);
Cn=Cn.^2;

end


function [Shifts,C]=get_shifts_main(X)
X=v2uint8(X);
d3=size(X,3);
% [D,ans] = imregdemons(Vf(:,:,i),Vf(:,:,i-1));

    Shifts=get_shift_in(squeeze(X(:,:,2,:)),X(:,:,1,:));

P=squeeze(X(:,:,1,1));
P(:,:,2)=imwarp(squeeze(X(:,:,2,1)),Shifts,'FillValues',nan);


 P=reshape(P,size(P,1)*size(P,2),[]);

 C=min(1-pdist(P','correlation')); 


end

function out=get_shift_in(M1,X)

opt = struct('niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);
[d1,d2,~,~]=size(X);

t_shifts=zeros(d1,d2,2,size(X,3));
for k=1:size(X,3)
    M2=squeeze(X(:,:,k,:));
    [t1,t2,t_shifts(:,:,:,k)]=MR_Log_demon(M1,M2,opt);
end
out=sum(-t_shifts,4,'omitnan');
end







