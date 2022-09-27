function out=load_avi(path)
% tic;four=load_avi('D:\5.avi');toc;
 v = VideoReader(path);
numFrames = v.NumFrames;
for i = 1:numFrames
    out(:,:,i) = rgb2gray(read(v,i));
end