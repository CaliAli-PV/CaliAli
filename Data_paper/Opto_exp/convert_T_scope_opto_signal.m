function y=convert_T_scope_opto_signal(t,f)
%% t is the copy pase from the cvx data (both columns)
%% f= is the number of frames

[s,pks] = findpeaks(double(t(:,1)>2),'MinPeakHeight',0.9);

O=t(pks(1):pks(end),2);

y = resample(O,f,length(O))>1;