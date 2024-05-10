function ISXD2h5(inputFilePath,ds_f,outpath)
% ISXD2h5('C:\Users\BigBrain\Desktop\Sakthi_data\test.isxd',4)


% Test that Inscopix MATLAB API ISX package installed
try
    inputMovieIsx = isx.Movie.read(inputFilePath);
catch
    if ismac
        baseInscopixPath = './';
    elseif isunix
        baseInscopixPath = './';
    elseif ispc
        baseInscopixPath = 'C:\Program Files\Inscopix\Data Processing';
    else
        disp('Platform not supported')
    end

    if exist(baseInscopixPath,'dir')==7
    else
        baseInscopixPath = '.\';
    end
    if exist(baseInscopixPath,'dir')
        pathToISX = baseInscopixPath;
    else
        pathToISX = uigetdir(baseInscopixPath,'Enter path to Inscopix Data Processing program installation folder (e.g. +isx should be in the directory)');
    end
    addpath(pathToISX);
    help isx
end




inputMovieIsx = isx.Movie.read(inputFilePath);
nFrames = inputMovieIsx.timing.num_samples;

[filepath,name]=fileparts(inputFilePath);
if isempty(outpath)
    out=strcat(filepath,filesep,name,'_ds','.h5');
else
    out=strcat(outpath,filesep/Volumes/CharZaku/20230217-jY586LW-SMP2,name,'_ds','.h5');
end
f=inputMovieIsx.get_frame_data(0);
vid=zeros(size(f,1)/ds_f,size(f,2)/ds_f,nFrames,class(f));
for i=progress(1:nFrames)
    f=inputMovieIsx.get_frame_data(i-1);
    vid(:,:,i)=imresize(f,1/ds_f,'bilinear');
end
saveash5(vid,out);



