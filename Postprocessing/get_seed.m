function seed_all=get_seed(neuron)

app=manual_residuals_PNR(neuron.CaliAli_options.inter_session_alignment.Cn,neuron.CaliAli_options.inter_session_alignment.PNR,neuron.Cnr,neuron.PNRr);

app.done=0;
while app.done == 0  % polling
    pause(0.05);
end
seed_all=find(app.seed);
delete(app);
