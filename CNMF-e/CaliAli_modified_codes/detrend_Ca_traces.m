function out=detrend_Ca_traces(nums,obj,F)
if ~exist('F','var')
    F=size(obj,2);
end

obj=double(obj);
BL=obj;
k=0;
for j=1:size(F,2)
    x=obj(:,k+1:k+F(j));
    out=[];
    parfor i=1:size(obj,1)
        temp=medfilt1(x(i,:),nums*10,'truncate');
        bl=imerode(temp', ones(nums*50, 1))';
        %     bl(bl>0)=0;
        %     plot(neuron.C_raw(i,:));hold on;plot(temp);plot(bl);
        % BL(i,:)=bl;
        out(i,:)=x(i,:)-bl;
    end
    Oc{j}=out;
    k=k+F(j);
end

out=cat(2,Oc{:});