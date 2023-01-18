function y=convert_T_scope_opto_signal(t,f)

[s,pks] = findpeaks(double(t(:,1)>2),'MinPeakHeight',0.9);

O=t(pks(1):pks(end),2);

y = resample(O,f,length(O))>1;