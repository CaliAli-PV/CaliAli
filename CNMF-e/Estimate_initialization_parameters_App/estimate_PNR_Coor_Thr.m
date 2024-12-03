function neuron=estimate_PNR_Coor_Thr(inF)

CaliAli_options=CaliAli_load(inF,'CaliAli_options');
neuron=CaliAli_options.cnmf;

m=CaliAli_options.inter_session_alignment;
if isempty(neuron.seed_mask)
    neuron.seed_mask=ones(size(m.Cn));
end
v_max=CaliAli_get_local_maxima(CaliAli_options);
app=estimate_Corr_PNR(m.Cn,m.PNR,v_max,neuron.min_corr,neuron.min_pnr,logical(neuron.seed_mask));
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end
neuron.seed_mask=app.mask;
neuron.Cn=app.cn;
neuron.PNR=app.pnr;
neuron.ind=app.tmp_ind;
neuron.min_pnr=app.PNRSpinner.Value;
neuron.min_cn=app.corrSpinner.Value;% get the values set in the parameter window
delete(app);





