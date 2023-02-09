function T=get_real_data()
% [out]=get_real_data();
Ce=create_file_list_reg_exp();



%% Get CaliAli
[CA.a,CA.c,CA.cr,CA.d]=get_data_conc(Ce{1});
%% Get CellReg alignment
[CR.a,CR.c,CR.cr,CR.d]=get_data_cellReg(Ce(2:end),'Translation');

%% Get SCOUT alignment
%     [SCo.a,SCo.c,SCo.cr,SCo.d]=get_data_scout(Ce(4:end));
%     SCo=align_shapes_con(GT,SCo);
%     [SCo.m,SCo.s]=calculate_best_matching_score2(GT.a,SCo.a,GT.c,SCo.c);
%     SCo.t=get_errors_2(SCo.m,size(GT.c,1));

%% Get SCOUT defaul
[SCOUT.a,SCOUT.c,SCOUT.cr,SCOUT.d]=get_data_scout(Ce(2:end));

%    show_neuron_tracking_exp(id,GT,CR)
%     T1=cell2table({CR.s,CR.t,SC.s,SC.t,PC.s,PC.t,SCo.s,SCo.t},'VariableNames',{'CellReg Reconstruction','CellReg errors','SessCon Reconstruction','CellCon errors','GT Reconstruction','GT errors','SCOUT Reconstruction','SCOUT errors'});

T=cell2table({CR,SCOUT,CA},'VariableNames',{'CellReg','SCOUT','CaliAli'});

end


function out=create_file_list_reg_exp()
theFiles = uipickfiles('FilterSpec','*det.h5');
[path,name]=fileparts(theFiles{end});
name=name(1:end-4);
%% get Aligned data
list= dir( [path,'\',name,'_Aligned_source_extraction\frames_1_*\**\*.mat']);
out{1,1}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];

%% get individual sessions
for k=1:size(theFiles,2)
    [path,name]=fileparts(theFiles{k});
    list= dir( [path,'\',name,'_source_extraction\frames_1_*\**\*.mat']);
    out{1,1+k}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
end
%% get SCOUT links
%
%      for k=1:In-1
%          list= dir( [path,'\',name,'_ses*_Link_',sprintf('%02d',k),'*source_extraction\frames_1_*\**\*.mat']);
%          link{i,k}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
%      end
end





