function vid=ISXD2h5(inputFilePath)
% ISXD2h5('C:\Users\BigBrain\Desktop\Sakthi_data\test.isxd')


% Test that Inscopix MATLAB API ISX package installed
try
    inputMovieIsx = isx.Movie.read(inputFilePath);
catch
    if ismac
        baseInscopixPath = '/Applications/Inscopix Data Processing.app/Contents/API/MATLAB';
    elseif isunix
        baseInscopixPath = './Inscopix Data Processing.linux/Contents/API/MATLAB';
    elseif ispc
        baseInscopixPath = 'C:\Program Files\Inscopix\Data Processing';
    else
        disp('Platform not supported')
    end

    if ~exist(baseInscopixPath,'dir')==7
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
f=inputMovieIsx.get_frame_data(0);
vid=zeros(size(f,1)/ds_f,size(f,2)/ds_f,nFrames,class(f));
for i=progress(1:nFrames)
    vid(:,:,i)=inputMovieIsx.get_frame_data(i-1);
end




