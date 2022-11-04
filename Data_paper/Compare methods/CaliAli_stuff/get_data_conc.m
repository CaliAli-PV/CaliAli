function [a,c,c_raw,d,s]=get_data_conc(s)
load(s,'neuron');
d1=neuron.options.d1;
d2=neuron.options.d2;
d=[d1,d2];
a=full(neuron.A);
c1=neuron.C(:,1:end/2);
c2=neuron.C(:,end/2+1:end);
c1r=neuron.C_raw(:,1:end/2);
c2r=neuron.C_raw(:,end/2+1:end);

c=[c1,c2];
% n=max(c,[],2);
% c=c./n;
c_raw=[c1r,c2r];
s=neuron.S;
% c_raw=c_raw./n;
end

