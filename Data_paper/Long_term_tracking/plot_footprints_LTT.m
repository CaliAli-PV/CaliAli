function [out]=plot_footprints_LTT()
% [out]=cell_tracking_long_term();
% save('results.mat','-v7.3');


theFiles = uipickfiles('FilterSpec','*.h5')';
tiledlayout('flow');
for i=1:size(theFiles,1)
    [path,name]=fileparts(theFiles{i});
    list= dir( [path,'\',name,'_source_extraction\frames_1_*\**\*.mat']);
    fname=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
    
end


end

    

