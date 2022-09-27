function C=get_BV_corr()
theFiles = uipickfiles('FilterSpec','*Aligned.mat');

for i=1:size(theFiles,2)
    try
    load(theFiles{1, i},'P');
    T=P.(3)(1,:).Vessel{1,1};
    C(i,1)=min(1-pdist(reshape(T,size(T,1)*size(T,2),[])','correlation'));
    catch
dummy=1
    end
end

