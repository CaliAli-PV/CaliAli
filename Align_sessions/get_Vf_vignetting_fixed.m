function M=get_Vf_vignetting_fixed(M,opt)
if ~exist('opt','var')
    opt.BVz=[0.6*2.5,0.9*2.5];
end


if size(M,3)>1
    parf=1;
else
    parf=0;
end
M=single(M);
sz=round(max(size(M,[1,2]))/8);
se = offsetstrel('ball',sz,0.01);

[~,gradThresh,numIter]=remove_vignetting(M(:,:,1),se);


if parf==1
    M=create_batches(M);
    b = ProgressBar(size(M,1), ...
        'IsParallel', true, ...
        'UpdateRate', 1,...
        'WorkerDirectory', pwd(), ...
        'Title', 'Appling diffuse filter' ...
        );
    b.setup([], [], []);
    bv_scale=linspace(opt.BVz(1),opt.BVz(2),10);
    parfor i=1:size(M,1)
        M{i}=process_batch(M{i},se,gradThresh,numIter,bv_scale)
        updateParallel([], pwd);
    end
    b.release();
    M=cat(3,M{:});
else
    [M,~,~]=remove_vignetting(M,se,gradThresh,numIter);
    M=M+randn(size(M))/10000;
    M=mat2gray(vesselness_PV(M,0,linspace(opt.BVz(1),opt.BVz(2),10),0));
    M=medfilt2(M,'symmetric');
end

end

function [M,gradThresh,numIter]=remove_vignetting(M,se,gradThresh,numIter)

R=M-imopen(M,se);
if ~exist('gradThresh','var')
    [gradThresh,numIter] = imdiffuseest(R,'ConductionMethod','quadratic');
end

M = mat2gray(imdiffusefilt(R,'ConductionMethod','quadratic', ...
    'GradientThreshold',gradThresh,'NumberOfIterations',numIter));
end

function M=create_batches(M)
[d1, d2, f] = size(M);   % Get the dimensions of the original array
batch_size = 100;        % Define the batch size

% Calculate the size of each batch along the third dimension
batch_sizes = [repmat(batch_size, 1, floor(f / batch_size)), mod(f, batch_size)];

% Remove the last entry if it is 0, since mod(f, batch_size) could be 0
if batch_sizes(end) == 0
    batch_sizes(end) = [];
end
M = squeeze(mat2cell(M, d1, d2, batch_sizes));
end

function in=process_batch(in,se,gradThresh,numIter,bv_scale)
    [d1, d2, num_frames] = size(in);
    noise = randn(d1, d2, 'single') / 10000; % Precompute noise array
    for i = 1:num_frames
        frame = in(:,:,i);
        frame = remove_vignetting(frame, se, gradThresh, numIter);
        frame = frame + noise;  % Add precomputed noise
        frame = mat2gray(vesselness_PV(frame, 0, bv_scale, 0));
        in(:,:,i) = medfilt2(frame, 'symmetric');  % Update the frame directly
    end
end

