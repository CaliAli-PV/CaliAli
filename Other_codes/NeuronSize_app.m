function r=NeuronSize_app(lim)

if ~exist('lim','var')
lim=1:0.5:5;
end

theFiles = uipickfiles('REFilter','\.mat*$','num',1);
V=CaliAli_load(theFiles{1, 1}  ,'Y');

if contains(theFiles{1, 1},'_mc')
    M=max(V,[],3);
else
    id=squeeze(max(V,[],[1,2]));
    [~,I]=max(id);
    M=V(:,:,I);
end

[M,~]=remove_borders(M,0);


N=neuron_stack(M,lim);

app=NeuronSize_app_in(N,lim);
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end

r=app.Slider.Value;
fprintf('The chosen Neuron size is [%.2f]\n',r);
delete(app);
end


function out=neuron_stack(M,lim)

for i=1:numel(lim)
    Y=M;
    gSig=lim(i);
    szad=gSig*2;
    Y=single(mat2gray(Y));
    dc = dirt_clean(Y, szad, 0);
    Y = dc + Y;
    clear dc;
    Y = anidenoise(Y, round(szad),0,4,0.1429, 0.5,1);
    out(:,:,i) = mat2gray(bg_remove(Y, round(szad),1));
end

end