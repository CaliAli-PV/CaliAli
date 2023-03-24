function [out]=cell_tracking_main()
% [out]=cell_tracking_main();
% save('results.mat','-v7.3');
%% modify line 74 wiht sprintf('%02d',k-1) for new files
[in,link]=create_file_list_reg_exp();

out=table;
for i=1:size(in,1)
    Ce=in(i,:);
    
    %% get ground truth
    [GT.a,GT.c,GT.d]=get_GT_data(Ce{1});
    %% Get GT data post-cnmfe (PC)
    [optimal.a,optimal.c,optimal.cr,optimal.d]=get_data_conc(Ce{2});
    optimal=align_shapes_con(GT,optimal);
    optimal.m=calculate_best_matching_score2(GT.a,optimal.a,GT.c,optimal.c);
    [optimal.t,optimal.s]=get_errors_2(optimal.m,size(GT.c,1));
    %% Get CaliAli
    [CA.a,CA.c,CA.cr,CA.d]=get_data_conc(Ce{3});
    CA=align_shapes_con(GT,CA);
    [CA.m]=calculate_best_matching_score2(GT.a,CA.a,GT.c,CA.c);
    [CA.t,CA.s]=get_errors_2(CA.m,size(GT.c,1)); 
    %% Get CellReg alignment
    [CR.a,CR.c,CR.cr,CR.d]=get_data_cellReg(Ce(4:end),'Non-rigid');
    CR=align_shapes_con(GT,CR);
    CR.m=calculate_best_matching_score2(GT.a,CR.a,GT.c,CR.c);
    [CR.t,CR.s]=get_errors_2(CR.m,size(GT.c,1));
    %% Get SCOUT alignment
    if size(Ce(4:end),2)>15
        re=false;
    else
        re=true;
    end
          opt=struct('max_gap',20,'weights',[1,1,1,1,1,1], ...
                'registration_method',{{'translation','non-rigid'}},'probability_assignment_method','Kmeans', ...
                'chain_prob',0.5,'min_prob',0.5,'max_dist',80,'reconstitute',re);

    [SCOUT.a,SCOUT.c,SCOUT.cr,SCOUT.d]=get_data_scout(Ce(4:end),link(i,:),opt);
    SCOUT=align_shapes_con(GT,SCOUT);
    SCOUT.m=calculate_best_matching_score2(GT.a,SCOUT.a,GT.c,SCOUT.c);
    [SCOUT.t,SCOUT.s]=get_errors_2(SCOUT.m,size(GT.c,1));

    %    show_neuron_tracking_exp(id,GT,CR)
    %     T1=cell2table({CR.s,CR.t,SC.s,SC.t,PC.s,PC.t,SCo.s,SCo.t},'VariableNames',{'CellReg Reconstruction','CellReg errors','SessCon Reconstruction','CellCon errors','GT Reconstruction','GT errors','SCOUT Reconstruction','SCOUT errors'});
    
    T1=cell2table({CR,SCOUT,CA,optimal},'VariableNames',{'CellReg','SCOUT','CaliAli','Optimal'});
    out=[out;T1];
end


end




%% Load concatenation data.

function [A,C,d]=get_GT_data(in);
load(in,'A','C');
C=C./max(C,[],2);
[d1,d2,~]=size(A{1, 1});
d=[d1,d2];
A=reshape(A{1},d1*d2,[]);
end

function [out,link]=create_file_list_reg_exp()
theFiles = uipickfiles('FilterSpec','*GT.mat');
for i=1:size(theFiles,2)

    [path,name]=fileparts(theFiles{i});
    name=name(1:end-3);
    F=dir([path,'\',name,'*.h5']);

    out{i,1}=[path,'\',name,'.mat']; %get GT
    %% get cnmf_data
    list= dir( [path,'\',name,'_GT_source_extraction\frames_1_*\**\*.mat']);
    out{i,2}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];

    %% get Aligned data
    list= dir( [path,'\',name,'_ses*_Aligned_source_extraction\frames_1_*\**\*.mat']);
    out{i,3}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
     In=length(dir([path,'\',name,'_ses*_det.h5']));
     %% get individual sessions
    for k=1:In
     list= dir( [path,'\',name,'_ses',sprintf('%d',k-1),'_det_source_extraction\frames_1_*\**\*.mat']); 
     out{i,3+k}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
    end
     %% get SCOUT links
    
     for k=1:In-1
         list= dir( [path,'\',name,'_ses*_Link_',sprintf('%02d',k),'*source_extraction\frames_1_*\**\*.mat']);
         link{i,k}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
     end


end
    
end
    
    

