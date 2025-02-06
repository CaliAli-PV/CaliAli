function seed=get_seed_dendrites(neuron)

Cn=neuron.CaliAli_options.inter_session_alignment.Cn;
PNR=neuron.CaliAli_options.inter_session_alignment.PNR;
X=Cn.*PNR;
I=(Cn>=neuron.CaliAli_options.cnmf.min_corr & neuron.CaliAli_options.cnmf.seed_mask).*(PNR>=neuron.CaliAli_options.cnmf.min_pnr & neuron.CaliAli_options.cnmf.seed_mask);

SE = strel('line', neuron.CaliAli_options.preprocessing.median_filtering(1), 90);

I=imopen(I,SE);

for i=1:3
I= remove_small_regions(I,neuron.CaliAli_options.cnmf.min_pixel);
I=imopen(I,SE);
end

I = bwmorph(I, "thin", Inf);
I= medfilt2(I,[5,1]);
I = bwmorph(I,"diag");
I= remove_small_regions(I,neuron.CaliAli_options.cnmf.min_pixel/2);
seed = bwmorph(I,"shrink",Inf);

seed=find(double(seed(:)));
[~,I]= sort(X(seed));
seed=seed(I);
