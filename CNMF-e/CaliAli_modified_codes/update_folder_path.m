function neuron=update_folder_path(neuron)
new_path=uigetdir(cd,'Choose the ''source_extraction'' folder');
list=dir([new_path,filesep,'*',filesep,'*']);
p_folder=[list(size(list,1)).folder,filesep,list(size(list,1)).name];
neuron.P.log_file=strcat(p_folder,filesep,'log_',date,'.txt');
neuron.P.log_folder=strcat(p_folder,filesep); %update the folder

list=dir([new_path,filesep,'*.mat']);
neuron.P.mat_data   = matfile([list.folder,filesep,list.name]);