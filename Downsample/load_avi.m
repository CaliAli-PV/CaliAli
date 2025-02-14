function out=load_avi(path,numFrames)
if ~ismac
    % tic;four=load_avi('D:\5.avi');toc;
    v = VideoReader(path);
    if ~exist('numFrames','var')
        numFrames = v.NumFrames;
    end

    if numFrames>v.NumFrames
        numFrames = v.NumFrames;
    end

    for i = 1:numFrames
        out(:,:,i) = rgb2gray(read(v,i));
    end
else
    out = loadGrayAVIwithFFmpeg(path);
end