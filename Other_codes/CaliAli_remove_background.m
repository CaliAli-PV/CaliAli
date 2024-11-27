function Y=CaliAli_remove_background(Y,opt)
if opt.preprocessing.detrend>1
    Y=detrend_vid(Y,opt);
end

if opt.preprocessing.noise_scale
    Y=noise_scaling(Y);
end

if opt.preprocessing.neuron_enhance
    Y=MIN1PIPE_bg_removal(Y,opt);
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
Y=mat2gray(reshape(Y,[d1*d2,d3]))*100;
Y=Y+randn(size(Y));
Y=Y./GetSn(Y);
Y(isnan(Y))=0;
Y(isinf(Y))=0;
Y=reshape(Y,[d1,d2,d3]);
end

function Y=detrend_vid(Y,opt)
[d1,d2,d3]=size(Y);
Y = detrend_PV(opt.sf*opt.preprocessing.detrend,reshape(Y,[d1*d2,d3]));
Y=reshape(Y,d1,d2,d3);
end
