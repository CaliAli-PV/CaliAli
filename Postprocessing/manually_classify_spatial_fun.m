function ix=manually_classify_spatial_fun(neuron,ix)
if ~exist('ix','var')
    ix=true(size(neuron.A,2),1);
end
                            
                
app=manually_classify_spatial(neuron,ix);
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end
[~,I]=sort(app.id);
ix=app.ix(I);
delete(app);