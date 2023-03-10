function [out]=optimal_SCOUT()
% [out]=optimal_SCOUT();
% save('results.mat','-v7.3');
%% modify line 74 wiht sprintf('%02d',k-1) for new files
[in,link]=create_file_list_reg_exp();

for k=1:size(in,1)
    Ce=in(k,:);
    p=0.1:0.1:0.8;
    %% get ground truth
    [GT.a,GT.c,GT.d]=get_GT_data(Ce{1});
    out_t=zeros(numel(p),numel(p));
    for i=1:numel(p)
        i
        for j=1:numel(p)
            j
            %% Get SCOUT alignment
            opt=struct('max_gap',20,'weights',[1,1,1,1,1,1], ...
                'registration_method',{{'translation','non-rigid'}},'probability_assignment_method','Kmeans', ...
                'chain_prob',p(i),'min_prob',p(j));
            [SCOUT.a,SCOUT.c,SCOUT.cr,SCOUT.d]=get_data_scout(Ce(4:end),link(k,:),opt);
            SCOUT=align_shapes_con(GT,SCOUT);
            SCOUT.m=calculate_best_matching_score2(GT.a,SCOUT.a,GT.c,SCOUT.c);
            [SCOUT.t,SCOUT.s]=get_errors_2(SCOUT.m,size(GT.c,1));
          out_t(i,j)=SCOUT.s;  
        end
    end
    out{k}=out_t;
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
    
    

