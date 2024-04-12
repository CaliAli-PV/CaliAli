function [dM,D]=Add_NRmotion_reg(M,magnitude,msz)
%%
if ~exist('magnitude','var')
    magnitude=6;
end
if ~exist('msz','var')
    msz=15;
end
% Mask=mat2gray(imgaussfilt(mat2gray(M(:,:,1)),15,'FilterSize',51));
[d1,d2,~]=size(M);
for i=1:size(M,3);
    img1=mat2gray(imgaussfilt(randn(d1,d2),msz,'FilterSize',2001,'Padding','circular'));
    % img1=img1.*Mask;

    [Gx,Gy] = imgradientxy(img1);
    Gx=(mat2gray(Gx)-0.5)*2*magnitude;
    Gy=(mat2gray(Gy)-0.5)*2*magnitude;
    D=[];
    D(:,:,1)=Gy;
    D(:,:,2)=Gx;


    dM(:,:,i) = imwarp(M(:,:,i),D);
end

