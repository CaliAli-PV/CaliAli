function [A,C,C_raw,d,S]=get_data_scout(Ses,links)

for i=1:size(Ses,2)
    load(Ses{1,i},'neuron');
    c{i}=neuron.C;
    cr{i}=neuron.C_raw;
    s{i}=neuron.S;
    ta=full(neuron.A);
    ta=ta./max(ta);
    d{i}=[neuron.options.d1,neuron.options.d2];
    ta=smooth_a(ta,d{i});
    a{i}=ta;
    neuron.A=ta;
    neurons{i}=neuron;

end
if exist('links','var')
    for i=1:size(links,2)
        load(Ses{1,i},'neuron');
        neuron.A=full(neuron.A);
        links{i}=neuron;
    end
else
    links={};
end

if isempty(links)
    [neu,map,~,~]=cellTracking_SCOUT(neurons,'max_gap',5,'weights',[0,1/5,1/5,1/5,1/5,1/5], ...
        'registration_method',{'translation','non-rigid'});  %correlation, centroid_dist,overlap,JS,SNR,decay
else
    [neu,map,~,~]=cellTracking_SCOUT(neurons,'links',links, ...
        'max_gap',5,'weights',[1/6,1/6,1/6,1/6,1/6,1/6], ...
        'registration_method',{'translation','non-rigid'});  %correlation, centroid_dist,overlap,JS,SNR,decay
end

d=max(cell2mat(d'));  
A=full(neu.A./max(neu.A));
C=neu.C;
C_raw=neu.C_raw;
S=neu.S;
kill=sum(C,2)==0;
A(:,kill)=[];
C(kill,:)=[];
C_raw(kill,:)=[];
S(kill,:)=[];
end




function  a=smooth_a(a,d)
h = fspecial('disk',3.5);
for i=1:size(a,2)
    t=mat2gray(reshape(a(:,i),d));
    t(t<0.5)=0;
    im=imfilter(t,h,'replicate');
    a(:,i)=im(:);
end
end






