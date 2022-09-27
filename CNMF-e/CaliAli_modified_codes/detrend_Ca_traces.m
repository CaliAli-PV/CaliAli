function [out,BL]=detrend_Ca_traces(nums,obj)
obj=double(obj);
BL=obj;
parfor i=1:size(obj,1)
    temp=medfilt1(obj(i,:),nums*10,'truncate');
    bl=imerode(temp', ones(nums*50, 1))';
    bl(bl>0)=0;
    %     plot(neuron.C_raw(i,:));hold on;plot(temp);plot(bl);
    BL(i,:)=bl;
    out(i,:)=obj(i,:)-bl;
end

    