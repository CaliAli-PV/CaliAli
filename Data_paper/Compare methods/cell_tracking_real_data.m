function out=cell_tracking_real_data()
% out=cell_tracking_real_data();

in=create_file_list_reg_exp_real_data();


disp('Processing GT');
out=table;
for i=1:size(in,1)
    try
    Ce=in(i,:);
    %% Get GT 
    [GT.a,GT.c,GT.cr,GT.d]=get_data_conc(Ce{1});
    %% Get concatenation data
    [SC.a,SC.c,SC.cr,SC.d]=get_data_conc(Ce{4});
     SC=align_shapes_con(GT,SC);
    [SC.m,SC.s]=calculate_best_matching_score2(GT.a,SC.a,GT.c,SC.c);
    SC.t=get_errors_2(SC.m,size(SC.c,1));
    %% Get CellReg alignment
    [CR.a,CR.c,CR.cr,CR.d]=get_data_cellReg(Ce(1,2:3),'Non-rigid');
    CR=align_shapes_con(GT,CR);
    [CR.m,CR.s]=calculate_best_matching_score2(GT.a,CR.a,GT.c,CR.c);
    CR.t=get_errors_2(CR.m,size(CR.c,1));

    %% Get SCOUT alignment
    [SCo.a,SCo.c,SCo.cr,SCo.d]=get_data_scout(Ce(1,2:3));
    SCo=remove_low_s2n(SCo);
    SCo=align_shapes_con(GT,SCo);
    [SCo.m,SCo.s]=calculate_best_matching_score2(GT.a,SCo.a,GT.c,SCo.c);
    SCo.t=get_errors_2(SCo.m,size(SCo.c,1));
    %
    T1=cell2table({CR.s,CR.t,SCo.s,SCo.t,SC.s,SC.t},'VariableNames', ...
        {'CellReg Reconstruction','CellReg errors','SCOUT Reconstruction','SCOUT errors','CaliALi Reconstruction','CaliAli errors'});
    out=[out;T1];
    catch e
        rethrow(e);
        dummy=1
    end
end


end




%% Load concatenation data.



function out=create_file_list_reg_exp_real_data()

theFiles = uipickfiles('FilterSpec','*GT*.h5');

out=cell(size(theFiles,2),4);

for i=1:size(theFiles,2)
    
    [path,name]=fileparts(theFiles{i});
    
    name=name(1:end-7);
    file=[path,'\',name];
    
    list=dir([file,'_GT_det_source_extraction\frames_1_*\**\*.mat']);
    out{i,1}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
    
    list=dir([file,'_s1_det_source_extraction\frames_1_*\**\*.mat']);
    out{i,2}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];

    list=dir([file,'_s2_det_source_extraction\frames_1_*\**\*.mat']);
    out{i,3}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];

    list=dir([file,'_s2_Aligned_source_extraction\frames_1_*\**\*.mat']);
    out{i,4}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
end

end

function T=remove_low_s2n(T);

I=max(T.cr,[],2)<20;

T.cr(I,:)=[];
T.c(I,:)=[];
T.a(:,I)=[];
end

    
    
    