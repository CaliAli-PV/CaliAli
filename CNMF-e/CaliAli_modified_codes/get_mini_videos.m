function [Y_box,HY_box,ind_nhood,center,sz]=get_mini_videos(Y,HY,seed,neuron)

d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
if numel(gSig)<2
gSiz=[gSig*6,gSig*6];
else
gSiz=gSig.*4*1.5;
end


Y_box={};
HY_box={};
ind_nhood={};
center={};
sz={};
for k = 1:length(seed)
    ind_p = seed(k);

    y0 = HY(ind_p, :);

    P=max(y0)/(median(abs(y0))/0.6745*3)<1;
    if P % signal is weak
        ind_nhood{k} = [];
        HY_box{k} = [];
        Y_box{k} = [];
        center{k} = [];
        sz{k} = [];
        continue;
    end

    [r, c]  = ind2sub([d1, d2], ind_p);
    rsub = round(max(1, -gSiz(2)+r):min(d1, gSiz(2)+r));
    csub = round(max(1, -gSiz(1)+c):min(d2, gSiz(1)+c));
    [cind, rind] = meshgrid(csub, rsub);
    [nr, nc] = size(cind);
    sz{k}=[nr, nc];
    ind_nhood{k} = sub2ind([d1, d2], rind(:), cind(:));
    HY_box{k} = HY(ind_nhood{k}, :);
    Y_box{k} = single(Y(ind_nhood{k}, :));
    center{k} = sub2ind([nr, nc], r-rsub(1)+1, c-csub(1)+1);
end




