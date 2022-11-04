function T=cell_tracking_opto_data()
% T=cell_tracking_opto_data();

Ce=create_file_list_reg_exp_real_data();


disp('Processing GT');
out=table;
for i=1:size(Ce,1)
try
    %% Get GT

    %% Get concatenation data
    [CA.a,CA.c,CA.cr,CA.d,CA.s]=get_data_conc(Ce{i,end});
    %% Get CellReg alignment
    [CR.a,CR.c,CR.cr,CR.d,CR.s]=get_data_cellReg(Ce(i,1:end-1),'Non-rigid');

    %% Get SCOUT alignment
    [SCo.a,SCo.c,SCo.cr,SCo.d,SCo.s]=get_data_scout(Ce(i,1:end-1));
    
catch e
    rethrow(e);
    dummy=1
end
t{i,:}={CA,CR,SCo};

end
T=cell2table(cat(1,t{:}),'VariableNames',{'CaliAli','CellReg','SCOUT'});
end




%% Load concatenation data.



function out=create_file_list_reg_exp_real_data()

theFiles = uipickfiles('FilterSpec','*det.h5');

out=cell(1,size(theFiles,2)+1);

for i=1:size(theFiles,2)
    [path,name]=fileparts(theFiles{i});

    file=[path,'\',name];
    logs=dir([file,'_source_extraction\frames_1_*\LOGS*']);
    for k=1:size(logs,1)
       list=dir([file,'_source_extraction\frames_1_*\',logs(k).name,'\*.mat']); 
        out{k,i}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
    end
end

logs=dir([file(1:end-3),'Aligned_source_extraction\frames_1_*\LOGS*']);
for k=1:size(logs,1)
    list=dir([file(1:end-3),'Aligned_source_extraction\frames_1_*\',logs(k).name,'\*.mat']);
    out{k,i+1}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
end
end



