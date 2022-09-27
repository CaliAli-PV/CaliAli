function [Score,err,dist,C]=compare_alignment_methods_vessel(inp)
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
    T=median(in,3);
    M(:,:,i)=T;
    fprintf(1, 'Obtaining Vesselness image\n');
%     T=T-gsmoothn(T, [0 50], 'Region', 'same');
    Vf(:,:,i)=vesselness_PV(T,0,[1.5,1.58,1.66,1.74,1.82,1.9,1.98,2.06,2.14,2.22]);
    Vf(:,:,i) = adapthisteq(Vf(:,:,i),'Distribution','exponential');
    temp=filter_video(in,2.5);
    fprintf(1, 'Obtaining Filtered image\n');
    Filt(:,:,i)=mat2gray(min(temp,[],3));
    fprintf(1, 'Obtaining Correlation image\n');
    det=det_video(in,10);
    [~,Cn(:,:,i),~]=get_PNR_coor_greedy_PV(det,3);
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
% Cn
X=cat(4,repelem(Cn,1,1,1,2),repelem(Cn,1,1,1,2));
[err(1,1),Score(1,1),dist(:,:,1),C(1)]=get_correction_score_W(X,Mot,A,BW);

% Vessel image 
X=cat(4,repelem(Vf,1,1,1,2),repelem(Vf,1,1,1,2));
[err(1,2),Score(1,2),dist(:,:,2),C(2)]=get_correction_score_W(X,Mot,A,BW);
% Vessel + Cn

X=cat(4,repelem(x,1,1,1,2),repelem(Vf,1,1,1,2));
[err(1,3),Score(1,3),dist(:,:,3),C(3)]=get_correction_score_W(X,Mot,A,BW);

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

function out=get_similarity_component(A,S)
a1=A{1, 1};

for k=1:size(S,4)
    a2=A{1, k};
    for i=1:size(a1,3)
        temp=imwarp(a2(:,:,i),S(:,:,:,k));
        temp_a1=a1(:,:,i);
        out(k,i)=1-get_cosine(temp_a1(:)',temp(:)');
    end

end
end


function [err,score,dist,C]=get_correction_score_W(X,Mot,A,BW)
% [M_s,~,~,~,~]=get_shifts_warp(M,0,0,2);

[D,C]=get_shifts_BV_Test(X);
D=D-D(:,:,:,1);
sim=get_similarity_component(A,D);
dist=get_cum(sim);
D=D.*BW;
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




