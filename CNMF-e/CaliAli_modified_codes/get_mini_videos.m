function [Y_box,HY_box,ind_nhood,center,sz]=get_mini_videos(Y,HY,seed,d1,d2,gSiz)

k=0;
Y_box={};
HY_box={};
ind_nhood={};
center={};
sz={};
for mcell = 1:length(seed)    
    ind_p = seed(mcell);
    
    y0 = HY(ind_p, :);
    
    P=max(y0)/(median(abs(y0))/0.6745*3)<1;
    if P % signal is weak
        continue;
    else
     k=k+1;   
    end
    
    [r, c]  = ind2sub([d1, d2], ind_p);
    rsub = max(1, -gSiz+r):min(d1, gSiz+r);
    csub = max(1, -gSiz+c):min(d2, gSiz+c);
    [cind, rind] = meshgrid(csub, rsub);
     [nr, nc] = size(cind);
     sz{k}=[nr, nc];
    ind_nhood{k} = sub2ind([d1, d2], rind(:), cind(:));
    HY_box{k} = HY(ind_nhood{k}, :);     
    Y_box{k} = single(Y(ind_nhood{k}, :));
    center{k} = sub2ind([nr, nc], r-rsub(1)+1, c-csub(1)+1);
end


    

    