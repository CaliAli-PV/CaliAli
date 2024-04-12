function Full_pipeline_single_file_avi()

%% Parameters
ds=2;  % downsampling factor;
sf=10;  %sampling frequency;
gSiz=2.5;  % filtering size
ef=1;  % Min1pipe robust background extraction

%% Choose input files and output folder
theFiles = uipickfiles('REFilter','\.avi$','Prompt','Choose .avi video');
outpath = uigetdir([],'Choose output folder');
%%  Downsampling
Downsample_avi(ds,outpath,theFiles);
cd(outpath);

%% Motion correction
filenames=get_path_in_folder('*.h5');
MC_Batch(filenames,0);

%% Video Alignment
filenames=get_path_in_folder('*mc.h5');
detrend_Batch(sf,gSiz,ef,filenames);

end


function get_gpio_data(outpath,theFiles)

for i=1:size(theFiles,2)
    TF(i) = contains(theFiles{1, i},'trig_0.isxd');
end

if (max(TF)==1)
    [filepath,name,~]=fileparts(theFiles{1, find(TF)});
    if ~isfile([outpath,'\',name,'.gpio'])
        copyfile([filepath,'\',name,'.gpio'],[outpath,'\',name,'.gpio'])
    else
        fprintf(1, 'File %s already exist in destination folder\n', [name,'.gpio']);
    end
end

end

function filenames=get_path_in_folder(str)
f= dir(str);
for i=1:size(f,1)
filenames{i} = [f(i).folder,'\',f(i).name];
end

end


