function [out,bl]=detrend_PV(nums,obj)
obj=double(obj);
bl=obj*0;
parfor i=1:size(obj,1)
    temp=medfilt1(obj(i,:),nums*10,'truncate');
    bl(i,:)=imerode(temp', ones(nums*50, 1))';
%     plot(neuron.C_raw(i,:));hold on;plot(temp);plot(bl);
    out(i,:)=obj(i,:)-bl(i,:);  
end

    