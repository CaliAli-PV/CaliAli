function [Mr,Vf,S]=motion_correct_PV(V,opt)

Vf=mat2gray(get_Vf_vignetting_fixed(V,opt));
% VF=uint8(VF*2^8);
[d1,d2,~] = size(Vf);

b1=d1/10;
b2=d2/10;

if size(V,3)<200
    binz=size(V,3);
else
binz=200;
end

options_r = NoRMCorreSetParms('d1',d1-b1*2,'d2',d2-b2*2,'bin_width',binz,'max_shift',20,'iter',1,'correct_bidir',false);

tic; [~,shifts,~] = normcorre_batch(Vf(b1+1:d1-b1,b2+1:d2-b2,:),options_r); toc % register filtered dat

% options_r = NoRMCorreSetParms('d1',d1,'d2',d2,'bin_width',200,'max_shift',20,'iter',1,'correct_bidir',false);

parfor i=1:size(V,3)
    S(i,:)=flip(squeeze(shifts(i).shifts)')
    Mr(:,:,i) = imtranslate(V(:,:,i),S(i,:),'FillValues',0);
    Vf(:,:,i) = imtranslate(Vf(:,:,i),S(i,:),'FillValues',0);
end
