function ix=postprocessing_app(neuron,thr)
                         
                
app=View_components(neuron,thr);
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end

ix=sum(app.c,2)==3;

delete(app);