function neuron=estimate_PNR_Coor_Thr(param_in)

CaliAli_options=CaliAli_load(param_in{1, 1},'CaliAli_options');
neuron=CaliAli_options.cnmf;

m=CaliAli_options.inter_session_alignment;
if isempty(neuron.seed_mask)
    neuron.seed_mask=ones(size(m.Cn));
end

app=estimate_Corr_PNR(m.Cn,m.PNR,param_in{1, 4},param_in{1, 3},param_in{1, 2},logical(neuron.seed_mask));
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end
neuron.seed_mask=app.mask;
neuron.Cn=app.cn;
neuron.PNR=app.pnr;
neuron.ind=app.tmp_ind;
neuron.min_pnr=app.PNRSpinner.Value;
neuron.min_corr=app.corrSpinner.Value;% get the values set in the parameter window
neuron.gSig=app.gSigSpinner.Value;
delete(app);





