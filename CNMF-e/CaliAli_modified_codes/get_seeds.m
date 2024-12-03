function seed=get_seeds(neuron)

v_max=CaliAli_get_local_maxima(neuron.CaliAli_opt);

Cn=neuron.CaliAli_opt.inter_session_alignment.Cn;
PNR=neuron.CaliAli_opt.inter_session_alignment.PNR;
ind = (v_max==Cn.*PNR);

Cn_ind = ind & (Cn>=neuron.options.min_corr & neuron.CaliAli_opt.cnmf.seed_mask);
PNR_ind = ind & (PNR>=neuron.options.min_pnr & neuron.CaliAli_opt.cnmf.seed_mask);

seed = Cn_ind & PNR_ind;

seed=find(double(seed(:)));
[~,I]= sort(v_max(seed));
seed=seed(I);

        % [d1,d2]=size(Cn);
        % [row,col] = ind2sub([d1,d2],seed);
        %close all;imagesc(v_max);hold on;
        % plot(col,row,'.r');drawnow;



