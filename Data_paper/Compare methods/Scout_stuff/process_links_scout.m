 
theFiles = uipickfiles('FilterSpec','*SCOUT*.h5');

for i=1:size(theFiles,2)
    try
    GCs_CNMFe_sim(theFiles{1, i},2.5,0.15,2.5,10);
    close all
    catch
    fail_files(i)=i;
    end
end