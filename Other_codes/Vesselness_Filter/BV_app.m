function BV_app()

theFiles = uipickfiles('REFilter','\.h5*$','num',1);
V=h5read(theFiles{1, 1}  ,'/Object');

if contains(theFiles{1, 1},'_mc')
    M=median(V,3);
else
    M=V(:,:,1);
end

[M,opt.Mask]=remove_borders(M,0);

if ~exist('opt','var')
    opt.BVz=[0.6*2.5,0.9*2.5];
end

sz=round(max(size(M))/8);
se = offsetstrel('ball',sz,0.01);
for i=1:size(M,3)
    R=M(:,:,i)-imopen(M(:,:,i),se);
    if i==1
        [gradThresh,numIter] = imdiffuseest(R,'ConductionMethod','quadratic');
    end
    C(:,:,i) = mat2gray(imdiffusefilt(R,'ConductionMethod','quadratic', ...
        'GradientThreshold',gradThresh,'NumberOfIterations',numIter));
end
C=C+randn(size(C))/10000;

BV= BV_stack(C,0.1:0.05:6, [1;1],false);

BV=mat2gray(BV);

app=BV_app_in(BV);
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end

r=app.Slider.Value;
fprintf('The chosen Blood vessels sizes are [%.2f, %.2f]\n',r(1),r(2));
delete(app);