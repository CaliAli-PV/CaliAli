function Mov=play_movie(neuron,batch_num)
if nargin<2, batch_num=1; end
d1=neuron.options.d1; d2=neuron.options.d2;
fn=[0,1000];
Y = single(neuron.load_patch_data([],[fn(batch_num)+1,fn(batch_num+1)]));
if ~ismatrix(Y), Y=reshape(Y,[],size(Y,3)); end
Y(isnan(Y))=0;
A=full(neuron.A);
color_map=componentColorMap(reshape(A,d1,d2,[]),1:size(A,2),'Plot',false);

useGPU = exist('gpuDeviceCount','builtin') && gpuDeviceCount>0;
if useGPU
    A = gpuArray(A);
    Cg = gpuArray(single(neuron.C(:,fn(batch_num)+1:fn(batch_num+1))));
    ns = gather(A * C_g);
else
    Cg = single(neuron.C(:,fn(batch_num)+1:fn(batch_num+1)));
    ns   = A * Cg;
end

bg = single(reconstruct_background_residual(neuron,[fn(batch_num)+1,fn(batch_num+1)]));
res = Y - ns - reshape(bg,[],size(Y,2));

Y = reshape(Y,d1,d2,[]);
bg = reshape(bg,d1,d2,[]);
res = reshape(res,d1,d2,[]);

X = cat(2,Y,bg,Y-bg);
X(X<0)=0;

if useGPU
    Ym_gpu = gpuArray.zeros(d1*d2, size(Cg,2), 3, 'single');
    for m = 1:3
        Ym_gpu(:,:,m) = A * (Cg .* color_map(:,m));
    end
    Ym = gather(Ym_gpu);
else
    Ym = zeros(d1*d2, size(Cg,2), 3, 'single');
    for m = 1:3
        Ym(:,:,m) = A * (Cg .* color_map(:,m));
    end
end
Y_mixed = permute(reshape(Ym,d1,d2,[],3),[1,2,4,3]);

m_scale = 256 / max([max(X,[],'all'), max(Y_mixed(:))]);
res_map = [[zeros(128,1);linspace(0,1,128)'],zeros(256,1),[linspace(1,0,128)';zeros(128,1)]];

res_mixed = gray2rgb(res * m_scale/2 + 128, res_map);
X_mixed   = gray2rgb(X * m_scale);

Mov = [X_mixed, uint8(Y_mixed * m_scale), res_mixed];
implay(Mov*4);
end

function [cmap, Ared] = componentColorMap(A, T, varargin)
%COMPONENTCOLORMAP  Color clustered spatial components using a fixed palette of distinguishable colors
%   [cmap, Ared] = COMPONENTCOLORMAP(A, T, ...)
%   Inputs:
%     A : d1×d2×N binary (or weighted) spatial segments
%     T : N×1 vector of integer cluster labels
%   Name/Value:
%     'NumColors' – number of distinguishable colors to generate (default: 10)
%     'Plot'      – logical, if true display colored map (default: false)
%   Outputs:
%     Ared : d1×d2×M merged masks (M = # unique labels in T)
%     cmap : M×3 RGB colormap; uses only the first NumColors from distinguishable_colors,
%            and ensures touching clusters differ by graph‐coloring.

% parse options
p = inputParser;
addParameter(p,'NumColors',10,@(x)isnumeric(x)&&isscalar(x)&&x>=1);
addParameter(p,'Plot',false,@(x)islogical(x)||(isnumeric(x)&&isscalar(x)));
parse(p,varargin{:});
nC = round(p.Results.NumColors);
doPlot = logical(p.Results.Plot);

% 1) Merge over‐segments into clusters
labels = unique(T);
M      = numel(labels);
[d1,d2,~] = size(A);
Ared   = false(d1,d2,M);
for m = 1:M
    Ared(:,:,m) = any(A(:,:, T==labels(m) ), 3);
end
[~,I]=max(Ared,[],3);
for m = 1:M
    Ared(:,:,m) = Ared(:,:,m).*single(I==m);
end


% 2) Build touching‐adjacency graph
adj = false(M);
for i = 1:M
    DT = bwdist(Ared(:,:,i));
    for j = i+1:M
        if any( Ared(:,:,j) & (DT==0), 'all' )
            adj(i,j) = true;
            adj(j,i) = true;
        end
    end
end

% 3) Generate fixed palette of nC distinguishable colors on black
palette = distinguishable_colors(nC, {'k'});

% 4) Greedy graph‐coloring to ensure touching clusters differ
%    only uses colors 1:nC
deg      = sum(adj,2);
[~,ord]  = sort(deg,'descend');  % color high‐degree first
colorIdx = zeros(M,1);
for k = ord'
    used = colorIdx(adj(k,:));
    used = used(used>0);
    avail = setdiff(1:nC, used, 'stable');
    if isempty(avail)
        % fallback if more neighbors than colors: reuse all colors
        avail = 1:nC;
    end
    colorIdx(k) = avail(1);
end
cmap = palette(colorIdx,:);

% 5) Optional plot
if doPlot
    L = zeros(d1,d2,'uint16');
    for m = 1:M
        L(Ared(:,:,m)) = m;
    end
    RGB = label2rgb(L, cmap, 'k', 'noshuffle');
    figure; imshow(RGB);
    title('Clustered Components Colored (black bg)');
end
end

