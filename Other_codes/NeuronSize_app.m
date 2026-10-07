function r=NeuronSize_app(lim)

if ~exist('lim','var')
lim=1:0.5:5;
end

theFiles = uipickfiles('REFilter','\.mat*$','num',1);
V=CaliAli_load(theFiles{1, 1}  ,'Y');

if contains(theFiles{1, 1},'_mc')
    M=max(V,[],3);
else
    id=squeeze(max(V,[],[1,2]));
    [~,I]=max(id);
    M=V(:,:,I);
end

M = crop_to_valid(M, theFiles{1, 1});


N=neuron_stack(M,lim);

app=NeuronSize_app_in(N,lim);
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end

r=app.Slider.Value;
fprintf('The chosen Neuron size is [%.2f]\n',r);
delete(app);
end


function out=neuron_stack(M,lim)

for i=1:numel(lim)
    Y=M;
    gSig=lim(i);
    szad=gSig*2;
    Y=single(mat2gray(Y));
    dc = dirt_clean(Y, szad, 0);
    Y = dc + Y;
    clear dc;
    Y = anidenoise(Y, round(szad),0,4,0.1429, 0.5,1);
    out(:,:,i) = mat2gray(bg_remove(Y, round(szad),1));
end

end


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
end
