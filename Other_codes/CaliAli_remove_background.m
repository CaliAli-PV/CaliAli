function Y=CaliAli_remove_background(Y,CaliAli_options)

if CaliAli_options.preprocessing.detrend>0
    Y=detrend_vid(Y,CaliAli_options);
end

if CaliAli_options.preprocessing.noise_scale
    Y=noise_scaling(Y);
end

if CaliAli_options.preprocessing.neuron_enhance
    if strcmp(CaliAli_options.preprocessing.structure,'neuron')
        Y=MIN1PIPE_bg_removal(Y,CaliAli_options);
    elseif strcmp(CaliAli_options.preprocessing.structure,'dendrite')
        Y=dendrite_bg_removal(Y,CaliAli_options);
    end
end

if CaliAli_options.preprocessing.noise_scale
    Y=noise_scaling(Y);
end


end

function Y=MIN1PIPE_bg_removal(Y,CaliAli_options)
gSig=CaliAli_options.gSig;
szad=gSig*2;
Y=single(mat2gray(Y));
dc = dirt_clean(Y, szad, 1);
Y = dc + Y;
clear dc;
Y = anidenoise(Y, round(szad),1,4,0.1429, 0.5,1);
Y = bg_remove(Y, round(szad),1);
end

function Y=noise_scaling(Y)
[d1,d2,d3]=size(Y);
Y=double(reshape(Y,[d1*d2,d3]));
Y=Y./max(Y,[],'all');
Y=Y+randn(size(Y))./10000;
Y=Y./GetSn(Y);
Y(isnan(Y))=randn(sum(isnan(Y),'all'),1);
Y(isinf(Y))=randn(sum(isinf(Y),'all'),1);
Y=reshape(Y,[d1,d2,d3]);
end

