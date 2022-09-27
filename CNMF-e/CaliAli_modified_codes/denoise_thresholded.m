function denoise_thresholded(neuron,thr_v)
sf=neuron.Fs  ;
cr=neuron.C_raw;
c=neuron.C;
s=neuron.S;

t=movmedian(cr,5,2);
if thr_v==0
    thr=abs(movmin(t,60*sf,2)).*2;
else
    thr=ones(1,size(neuron.C,2))*thr_v;
end
a=movmax(t,10*sf,2);

% plot(cr(5,:)); hold on;plot(c(5,:));plot(a(5,:));plot(thr(5,:));

c(a<thr)=0;
s(a<thr)=0;

s(min(c,[],2)<0,:)=0;
c(min(c,[],2)<0,:)=0;



neuron.C=c;
neuron.S=s;
end