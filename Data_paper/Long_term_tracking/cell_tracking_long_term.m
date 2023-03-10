function [out]=cell_tracking_long_term()
% [out]=cell_tracking_long_term();
% save('results.mat','-v7.3');

[det_list,link,CaliAli_path]=create_file_list_reg_exp();

out=table;
for i=1:size(CaliAli_path,1)
    %% Get CaliAli
    [CA.a,CA.c,CA.cr,CA.d]=get_data_conc(CaliAli_path{i});

    %% Get CellReg alignment
    [CR.a,CR.c,CR.cr,CR.d]=get_data_cellReg(det_list(1:i*2)','Non-rigid');

    %% Get SCOUT alignment
    [SCOUT.a,SCOUT.c,SCOUT.cr,SCOUT.d]=get_data_scout(det_list(1:i*2)',link(1:i*2-1)');
    T1=cell2table({CR,SCOUT,CA},'VariableNames',{'CellReg','SCOUT','CaliAli'},'RowNames',{['Sess ',num2str(i*2)]});
    out=[out;T1];
end


end



function [det_list,link,CaliAli_path]=create_file_list_reg_exp()
theFiles = uipickfiles('FilterSpec','*det.mat')';
for i=1:size(theFiles,1)
    [path,name]=fileparts(theFiles{i});
    list= dir( [path,'\',name,'_source_extraction\frames_1_*\**\*.mat']);
    det_list{i,1}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
end

list_link= dir( [path,'\','*link.h5']);
list_link=struct2cell(list_link)';
list_link=strcat(list_link(:,2),'\',list_link(:,1));

for i=1:size(list_link,1)
    [path,name]=fileparts(list_link{i});
    list= dir( [path,'\',name,'_source_extraction\frames_1_*\**\*.mat']);
    link{i,1}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
end

list= dir( [path,'\','*Aligned.h5']);
caliAli=struct2cell(list)';
caliAli=strcat(caliAli(:,2),'\',caliAli(:,1));

for i=1:size(caliAli,1)
    [path,name]=fileparts(caliAli{i});
    list= dir( [path,'\',name,'_source_extraction\frames_1_*\**\*.mat']);
    CaliAli_path{i,1}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
end

end

    

