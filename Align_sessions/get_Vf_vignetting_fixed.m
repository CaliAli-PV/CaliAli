function Vf=get_Vf_vignetting_fixed(M,opt)
if ~exist('opt','var')
    opt.BVz=[0.6*2.5,0.9*2.5];
end

sz=round(max(size(M))/8);
se = offsetstrel('ball',sz,0.01);
for i=1:size(M,3)
    R=M(:,:,i)-imopen(M(:,:,i),se);
    if i==1
        [gradThresh,numIter] = imdiffuseest(R,'ConductionMethod','quadratic');
    end
    C(:,:,i) = mat2gray(imdiffusefilt(R,'ConductionMethod','quadratic', ...
        'GradientThreshold',gradThresh,'NumberOfIterations',numIter));
end
C=C+randn(size(C))/10000;

Vf=mat2gray(vesselness_PV(C,1,linspace(opt.BVz(1),opt.BVz(2),10),0));
end