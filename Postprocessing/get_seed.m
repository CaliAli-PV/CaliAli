function seed_all=get_seed(neuron)
if isempty(neuron.Coor)
    neuron.Coor=neuron.get_contours(0.6);
end
app=manual_residuals_PNR(neuron.CaliAli_options.inter_session_alignment.Cn, ...
    neuron.CaliAli_options.inter_session_alignment.PNR, ...
    neuron.Cnr,neuron.PNRr, ...
    neuron.Coor);

app.done=0;
while app.done == 0  % polling
    pause(0.05);
end
seed_all=find(app.seed);
delete(app);
