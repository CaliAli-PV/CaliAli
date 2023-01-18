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



