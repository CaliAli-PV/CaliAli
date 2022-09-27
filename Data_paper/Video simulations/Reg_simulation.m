function Reg_simulation()

Ce = table2cell(readtable('parameters_sim.xlsx','Format','auto','ReadVariableNames', false));
% Mask=zeros(180,260);
% Mask(11:170,11:250)=1;

for i=1:size(Ce,1)
    try
    cd(Ce{i,2});
    [~,~,path,name]=Simulate_Ca_video_main(Ce{i,:});
    file_path=[path,'\',name];
    list=struct2cell(dir([file_path,'_ses*.h5']));
    list=strcat(list(2,:)','\',list(1,:)')';
    align_sessions_PV(10,2.5,list);
    detrend_Batch(10,2.5,list);
    delete(list{:});
    get_CnPNR_from_video(2.5,{[file_path,'_GT.h5']});    
    GCs_CNMFe_sim([file_path,'_GT.h5'],2.5,0.15,2.5,10);
    close all
    GCs_CNMFe_sim([file_path,'_ses',num2str(size(list,2)-1),'_Aligned.h5'],2.5,0.15,2.5,10);
    close all
    for k=1:size(list,2)
        [fp,name,ext]=fileparts(list{1, k});
        GCs_CNMFe_sim([fp,'\',name,'_det',ext],2.5,0.15,2.5,10);
    end

    catch
        dummy=1
    end
end

