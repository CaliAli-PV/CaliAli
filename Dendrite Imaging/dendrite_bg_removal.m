function Y=dendrite_bg_removal(Y,CaliAli_options)
[d1,d2,d3]=size(Y);
Y=reshape(Y,d1,d2,d3);

if ~isempty(CaliAli_options.preprocessing.median_filtering)
    sz=CaliAli_options.preprocessing.median_filtering;
    parfor i=1:size(Y,3)
        Y(:,:,i) = medfilt2(Y(:,:,i),sz);
    end
end
Y=mat2gray(Y);

dendrite_sz=CaliAli_options.preprocessing.dendrite_filter_size;

theta=CaliAli_options.preprocessing.dendrite_theta;
parfor i=1:size(Y,3)
    Y(:,:,i) = VerticalVesselness2D(Y(:,:,i),dendrite_sz, [1;1],theta,true,0);
end

