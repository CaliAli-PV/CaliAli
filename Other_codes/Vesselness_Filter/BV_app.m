function r=BV_app(lim)

if ~exist('lim','var')
lim=0.1:0.05:6;
end

theFiles = uipickfiles('REFilter','\.mat*$','num',1);
V=CaliAli_load(theFiles{1, 1}  ,'Y');

if contains(theFiles{1, 1},'_mc')
    M=median(V,3);
else
    M=mat2gray(V(:,:,round(size(V,3)/2))); 
    M = imgaussfilt(M, 1); 
end

[M,~]=remove_borders(M,0);

M = remove_vignetting_video_adaptive_batches(M);

BV= BV_stack(M,lim, [1;1],false);

app=BV_app_in(BV,lim);
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end

r=app.Slider.Value;
fprintf('The chosen Blood vessels sizes are [%.2f, %.2f]\n',r(1),r(2));
delete(app);