function Vf=get_Vf_vignetting_fixed(M,opt)
if ~exist('opt','var')
    opt.BVz=[0.6*2.5,0.9*2.5];
end

if size(M,3)>1
    parf=1;
else
    parf=0;
end
M=single(M);
if parf==1
    sz=round(max(size(M,[1,2]))/16);
    se = offsetstrel('ball',sz,0.01);
    R=M(:,:,1)-imopen(M(:,:,1),se);
    [gradThresh,numIter] = imdiffuseest(R,'ConductionMethod','quadratic');

    M=single(M);
    b = ProgressBar(size(M,3), ...
        'IsParallel', true, ...
        'UpdateRate', 1,...
        'WorkerDirectory', pwd(), ...
        'Title', 'Appling diffuse filter' ...
        );
    b.setup([], [], []);
    parfor i=1:size(M,3)
        M(:,:,i) = mat2gray(imdiffusefilt(M(:,:,i)-imopen(M(:,:,i),se),'ConductionMethod','quadratic', ...
            'GradientThreshold',gradThresh,'NumberOfIterations',numIter));
        updateParallel([], pwd);
    end
    b.release();
    M=M+randn(size(M),'single')/10000;

    Vf=mat2gray(vesselness_PV(M,parf,linspace(opt.BVz(1),opt.BVz(2),10),0));
    Vf=med_filt(Vf);

else
    sz=round(max(size(M,[1,2]))/8);
    se = offsetstrel('ball',sz,0.01);
    for i=progress(1:size(M,3))
        R=M(:,:,i)-imopen(M(:,:,i),se);
        if i==1
            [gradThresh,numIter] = imdiffuseest(R,'ConductionMethod','quadratic');
        end
        M(:,:,i) = mat2gray(imdiffusefilt(R,'ConductionMethod','quadratic', ...
            'GradientThreshold',gradThresh,'NumberOfIterations',numIter));
    end
    M=M+randn(size(M))/10000;

    Vf=mat2gray(vesselness_PV(M,parf,linspace(opt.BVz(1),opt.BVz(2),10),0));
    Vf=med_filt(Vf);
end


end

function Vf=med_filt(Vf)

if size(Vf,3)==1
    for i=1:size(Vf,3)
        Vf(:,:,i)=medfilt2(Vf(:,:,i),'symmetric');
    end
else
    parfor i=1:size(Vf,3)
        Vf(:,:,i)=medfilt2(Vf(:,:,i),'symmetric');
    end
end

end