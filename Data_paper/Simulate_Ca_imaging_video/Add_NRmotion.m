function [dM,dA,dbA,D]=Add_NRmotion(M,A,bA,magnitude,plotme,translation)
%%
if ~exist('magnitude','var')
    magnitude=2;
end

if ~exist('plotme','var')
    plotme=0;
end

if ~exist('translation','var')
    translation=0;
end

[d1,d2]=size(M);
img1=mat2gray(imgaussfilt(randn(d1,d2),60,'FilterSize',2001,'Padding','circular'));
[Gx,Gy] = imgradientxy(img1);
if translation>0
Gx=(mat2gray(Gx)-0.5)*2*magnitude+magnitude;
Gy=(mat2gray(Gy)-0.5)*2*magnitude+magnitude;
else
Gx=(mat2gray(Gx)-0.5)*2*magnitude;
Gy=(mat2gray(Gy)-0.5)*2*magnitude;
end
D=[];
D(:,:,1)=Gy;
D(:,:,2)=Gx;

dM = imwarp(M,D);
dM =dM (21:d1-20,21:d2-20,:);

dA = imwarp(A,D);
dA =dA(21:d1-20,21:d2-20,:);

dbA = imwarp(bA,D);
dbA =dbA(21:d1-20,21:d2-20,:);

M =M (21:d1-20,21:d2-20,:);
D=D(21:d1-20,21:d2-20,:);

if (plotme==1)
    subplot(2,2,1);
%     imshow(zeros(d1,d2));hold on;
    imshow(M);hold on;
    flow = opticalFlow(-Gx,-Gy);
    h1=plot(flow,'DecimationFactor',[25 25]); hold off;
    h = get(gca, 'Children');
    set(h(1), 'Color', 'b');
    
    subplot(2,2,2);imshow(dM, []); 
    subplot(2,2,3);imshow(mat2gray(M-dM));
    
    Vf1=vesselness_PV(M,0);
    Vf2=vesselness_PV(dM,0);
    If= imfuse(Vf1, Vf2,'ColorChannels',[1 2 0]);subplot(2,2,4);imshow(If)    
end

end