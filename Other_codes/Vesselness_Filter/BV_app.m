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

M = crop_to_valid(M, theFiles{1, 1});

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


function M = crop_to_valid(M, file)
% Keep the region motion correction recorded as real data. A file whose crop is
% still pending holds its Mask at the frame size; any other file is already
% cropped, or was never shifted, and is used whole. The pixel value is not
% consulted: a real pixel can be 0.
try
    Mask = CaliAli_load(file, 'CaliAli_options.motion_correction.Mask');
catch
    return
end
if isequal(size(Mask), size(M)) && any(Mask(:))
    [r, c] = find(Mask);
    M = M(min(r):max(r), min(c):max(c));
end
