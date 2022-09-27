function scale_to_noise(neuron)
%  We estimate the noise from the remnant between the raw and deconvolved calcium trace.
% we use a moving window of size=num
if size(neuron.frame_range,2)==1
    c=cumsum(neuron.frame_range);
    c=[[0;c(1:end-1)]+1,c];
else
    c=[neuron.frame_range(1),neuron.frame_range(2)];
end

for i=1:size(c,1)
    temp=neuron.C_raw(:,c(i,1):c(i,2)); % 1) we susbtract the deconvolved signal from the raw calcium trace.
    temp=detrend(temp')';
    temp=temp./GetSn(temp);   
    neuron.C_raw(:,c(i,1):c(i,2))=temp;   % 3) we scale the raw signal. 
end 

justdeconv(neuron,neuron.options.deconv_options.method,neuron.options.deconv_options.type,neuron.options.deconv_options.smin);
