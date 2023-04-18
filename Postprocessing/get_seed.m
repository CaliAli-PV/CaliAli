function seed_all=get_seed(neuron)

app=manual_residuals_PNR(mat2gray(neuron.Cn),neuron.PNR,mat2gray(neuron.Cnr),neuron.PNRr);

app.done=0;
while app.done == 0  % polling
    pause(0.05);
end
seed_all=find(app.seed);
delete(app);
