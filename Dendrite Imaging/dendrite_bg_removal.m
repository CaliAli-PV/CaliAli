function Y=dendrite_bg_removal(Y,opt)
[d1,d2,d3]=size(Y);
Y=reshape(Y,d1,d2,d3);

if ~isempty(opt.preprocessing.median_filtering)
    sz=opt.preprocessing.median_filtering;
    parfor i=1:size(Y,3)
        Y(:,:,i) = medfilt2(Y(:,:,i),sz);
    end
end
Y=mat2gray(Y);

dendrite_sz=opt.preprocessing.dendrite_size;
theta=opt.preprocessing.dendrite_theta;
parfor i=1:size(Y,3)
    Y(:,:,i) = VerticalVesselness2D(Y(:,:,i),dendrite_sz, [1;1],theta,true,0);
end

Y=mat2gray(Y);
