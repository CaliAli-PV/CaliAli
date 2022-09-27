function seed=get_seeds(Cn,PNR,gSig,min_corr,min_PNR,Mask)


tmp_d = max(1,round(gSig));
v_max = ordfilt2(Cn.*PNR, tmp_d^2, true(tmp_d));
ind = (v_max==Cn.*PNR);

Cn_ind = ind & (Cn>=min_corr & Mask) ;
PNR_ind = ind & (PNR>=min_PNR & Mask) ;

seed = Cn_ind & PNR_ind;

seed=find(seed);
[~,I]= sort(v_max(seed));
seed=seed(I);



