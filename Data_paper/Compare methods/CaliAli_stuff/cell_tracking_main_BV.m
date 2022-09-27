function out=cell_tracking_main_BV()
% out=cell_tracking_main_BV();
in=create_file_list_reg_exp();

out=table;
for i=1:size(in,1)
    Ce=in(i,:);
    
    %% get ground truth
    [GT.a,GT.c,GT.d]=get_GT_data(Ce{1});
    %% Get GT data post-cnmfe (PC)
    [PC.a,PC.c,PC.cr,PC.d]=get_data_conc(Ce{2});
    PC=align_shapes_con(GT,PC);
    [PC.m,PC.s]=calculate_best_matching_score2(GT.a,PC.a,GT.c,PC.c);
    PC.t=get_errors_2(PC.m,size(GT.c,1));
    %% Get CaliAli
    [SC.a,SC.c,SC.cr,SC.d]=get_data_conc(Ce{3});
    SC=align_shapes_con(GT,SC);
    [SC.m,SC.s]=calculate_best_matching_score2(GT.a,SC.a,GT.c,SC.c);
    SC.t=get_errors_2(SC.m,size(GT.c,1)); 
    %% Get CellReg alignment
    [CR.a,CR.c,CR.cr,CR.d]=get_data_cellReg(Ce(4:end),'Non-rigid');
    CR=align_shapes_con(GT,CR);
    [CR.m,CR.s]=calculate_best_matching_score2(GT.a,CR.a,GT.c,CR.c);
    CR.t=get_errors_2(CR.m,size(GT.c,1));
    %% Get SCOUT alignment
    [SCo.a,SCo.c,SCo.cr,SCo.d]=get_data_scout(Ce(4:end));
    SCo=align_shapes_con(GT,SCo);
    [SCo.m,SCo.s]=calculate_best_matching_score2(GT.a,SCo.a,GT.c,SCo.c);
    SCo.t=get_errors_2(SCo.m,size(GT.c,1));


    %    show_neuron_tracking_exp(id,GT,CR)
    %     T1=cell2table({CR.s,CR.t,SC.s,SC.t,PC.s,PC.t,SCo.s,SCo.t},'VariableNames',{'CellReg Reconstruction','CellReg errors','SessCon Reconstruction','CellCon errors','GT Reconstruction','GT errors','SCOUT Reconstruction','SCOUT errors'});
    
    T1=cell2table({CR.t,SCo.t,SC.t,PC.t},'VariableNames',{'CellReg','SCOUT','CaliAli','Optimal'});
    out=[out;T1];
end


end




%% Load concatenation data.

function [a,c,c_raw,d]=get_data_conc(s)
load(s,'neuron');
d1=neuron.options.d1;
d2=neuron.options.d2;
d=[d1,d2];
a=full(neuron.A);
c1=neuron.C(:,1:end/2);
c2=neuron.C(:,end/2+1:end);
c1r=neuron.C_raw(:,1:end/2);
c2r=neuron.C_raw(:,end/2+1:end);

c=[c1,c2];
n=max(c,[],2);
c=c./n;
c_raw=[c1r,c2r];
c_raw=c_raw./n;
end


function [A,C,d]=get_GT_data(in);
load(in,'A','C');
C=C./max(C,[],2);
[d1,d2,~]=size(A{1, 1});
d=[d1,d2];
A=reshape(A{1},d1*d2,[]);
end

function out=create_file_list_reg_exp()
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
     list= dir( [path,'\',name,'_ses',num2str(k-1),'_det_source_extraction\frames_1_*\**\*.mat']); 
     out{i,3+k}=[list(size(list,1)-1).folder,'\',list(size(list,1)-1).name];
    end
end
    
end
    
    

