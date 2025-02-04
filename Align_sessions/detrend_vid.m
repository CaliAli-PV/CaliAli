function Y=detrend_vid(Y,CaliAli_options)
[d1,d2,d3]=size(Y);
obj=reshape(single(Y),d1*d2,d3);
temp=movmedian(obj,CaliAli_options.preprocessing.sf*CaliAli_options.preprocessing.detrend,2);
temp=movmin(temp,CaliAli_options.preprocessing.sf*CaliAli_options.preprocessing.detrend*5,2);
Y=double(obj-temp);
Y(Y<0)=0;
Y=gather(reshape(Y,d1,d2,d3));
end
