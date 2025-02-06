function seed=get_seeds(neuron)

v_max=CaliAli_get_local_maxima(neuron.CaliAli_options);

Cn=neuron.CaliAli_options.inter_session_alignment.Cn;
PNR=neuron.CaliAli_options.inter_session_alignment.PNR;
ind = (v_max==Cn.*PNR);

if isempty(neuron.CaliAli_options.cnmf.seed_mask)
    neuron.CaliAli_options.cnmf.seed_mask=ones(size(Cn));
end
Cn_ind = ind & (Cn>=neuron.CaliAli_options.cnmf.min_corr & neuron.CaliAli_options.cnmf.seed_mask);
PNR_ind = ind & (PNR>=neuron.CaliAli_options.cnmf.min_pnr   & neuron.CaliAli_options.cnmf.seed_mask);

seed = Cn_ind & PNR_ind;

seed=find(double(seed(:)));
[~,I]= sort(v_max(seed));
seed=seed(I);

        % [d1,d2]=size(Cn);
        % [row,col] = ind2sub([d1,d2],seed);
        % close all;imagesc(Cn);hold on;
        % plot(col,row,'or');drawnow;



