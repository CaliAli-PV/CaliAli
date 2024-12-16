function Y=CaliAli_remove_background(Y,opt)

if opt.preprocessing.detrend>0
    Y=detrend_vid(Y,opt);
end

if opt.preprocessing.noise_scale
    Y=noise_scaling(Y);
end

if opt.preprocessing.neuron_enhance
    if strcmp(opt.preprocessing.structure,'neuron')
        Y=MIN1PIPE_bg_removal(Y,opt);
    elseif strcmp(opt.preprocessing.structure,'dendrite')
        Y=dendrite_bg_removal(Y,opt);
    end
end

end

function Y=MIN1PIPE_bg_removal(Y,opt)
gSig=opt.gSig;
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
Y=Y./max(Y,[],'all')*1000;
Y=Y+randn(size(Y));
Y=Y-median(Y,2);
Y=Y./GetSn(Y);
Y(isnan(Y))=randn(sum(isnan(Y),'all'),1);
Y(isinf(Y))=randn(sum(isinf(Y),'all'),1);
Y=reshape(Y,[d1,d2,d3]);
end

function Y=detrend_vid(Y,opt)
[d1,d2,d3]=size(Y);
obj=reshape(single(Y),d1*d2,d3);
temp=movmedian(obj,opt.sf*opt.preprocessing.detrend,2);
temp=movmin(temp,opt.sf*opt.preprocessing.detrend*10,2);
Y=double(obj-temp);
Y=gather(reshape(Y,d1,d2,d3));
end
