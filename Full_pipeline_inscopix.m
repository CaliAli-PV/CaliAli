function Full_pipeline_inscopix()

%% Parameters
ds=4;  % downsampling factor;
sf=10;  %sampling frequency;
gSiz=2.5;  % filtering size
ef=0;  % Min1pipe robust background extraction

%% Choose input files and output folder
theFiles = uipickfiles('REFilter','\.isxd$','Prompt','Choose .isxd video');
outpath = uigetdir([],'Choose output folder');
%%  Downsampling
Downsample_Inscopix(outpath,ds,theFiles);
get_gpio_data(outpath,theFiles)
cd(outpath);

%% Motion correction
f= dir('*.h5');
filenames = {f.name};
MC_Batch(filenames);

%% Video Alignment
f= dir('*mc.h5');
filenames = {f.name};
align_sessions_PV(sf,gSiz,ef,filenames);

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


