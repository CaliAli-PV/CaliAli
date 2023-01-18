function [a,c,c_raw,d,s]=get_data_conc(s)
load(s,'neuron');
d1=neuron.options.d1;
d2=neuron.options.d2;
d=[d1,d2];
a=full(neuron.A);
a=smooth_a(a,d);
c=neuron.C;
c_raw=neuron.C_raw;
s=neuron.S;
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
