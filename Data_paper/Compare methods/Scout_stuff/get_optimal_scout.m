function out=get_optimal_scout(S,links);

for i=1:size(S,2)
    load(S{1,i},'neuron');
    neurons{i}=neuron;
    c{i}=neuron.C;
    cr{i}=neuron.C_raw;
    ta=full(neuron.A);
    ta=ta./max(ta);
    ta(ta<0.5)=0;
    a{i}=ta;
    d{i}=[neuron.options.d1,neuron.options.d2];
end
if exist('links','var')
    for i=1:size(links,2)
        load(S{1,i},'neuron');
        links{i}=neuron;
    end
else
    links={};
end

if isempty(links)
    [neu,map,~,~]=cellTracking_SCOUT(neurons,'max_gap',5,'weights',[0,1/5,1/5,1/5,1/5,1/5]);  %correlation, centroid_dist,overlap,JS,SNR,decay
else
    [neu,map,~,~]=cellTracking_SCOUT(neurons,'links',links, ...
        'max_gap',5,'weights',[1/6,1/6,1/6,1/6,1/6,1/6], ...
        'registration_method',{'translation','non-rigid'},'chain_prob',[0.35,0.45], ...
        'min_prob',[0.35,0.45],'max_dist',[45,55]);  %correlation, centroid_dist,overlap,JS,SNR,decay
end

neu=squeeze(neu);
out=cell(size(neu));



for i=1:numel(neu);
    out{i}.d=max(cell2mat(d'));
    A_t=full(neu{i}.A./max(neu{i}.A));
    C_t=neu{i}.C;
    C_raw_t=neu{i}.C_raw;

    kill=sum(C_t,2)==0;
    A_t(:,kill)=[];
    C_t(kill,:)=[];
    C_raw_t(kill,:)=[];

    out{i}.a=A_t;
    out{i}.c=C_t;
    out{i}.cr=C_raw_t;
end


end





