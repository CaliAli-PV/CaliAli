function mc=get_local_corr_Vf(Vf,M)
%% get_local_corr_Vf: Compute local correlation-based similarity for vesselness-filtered data.
%
% Inputs:
%   Vf - 3D array containing vesselness-filtered images (blood vessels).
%   M  - 3D array representing the mean reference image.
%
% Outputs:
%   mc - 2D array representing the computed local correlation-based similarity map.
%
% Usage:
%   mc = get_local_corr_Vf(Vf, M);
%
% Notes:
%   - Computes pairwise similarity measures between frames.
%   - Uses histogram matching and median filtering for enhanced feature alignment.
%   - Applies a graph-based connectivity method to determine minimal local similarity.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Get the size of the input 3D array Vf
[d1,d2,d3]=size(Vf);

% Compute the mean reference image along the third dimension
M=mean(M,3);

% Generate all possible unique pairs of image frames
b=nchoosek(1:d3,2);

% Define a structuring element for morphological operations
SE = strel("disk",3);

% Loop over all unique image pairs
for i=1:size(b,1)
    % Extract two images from Vf
    im1=Vf(:,:,b(i,1));
    im2=Vf(:,:,b(i,2));
    
    % Normalize images to [0,1] and add small noise for robustness
    im1=mat2gray(im1)+randn(d1,d2)/1000;
    im2=mat2gray(im2)+randn(d1,d2)/1000;
    
    % Perform histogram matching for better alignment
    im1 = imhistmatch(im1,max(cat(3,im1,im2),[],3));
    im2 = imhistmatch(im2,max(cat(3,im1,im2),[],3));
    
    % Compute similarity using median filtering on pixel-wise product
    sim=medfilt2(im1.*im2);
    
    % Compute difference-based contrast information
    dif_c=medfilt2(max(cat(3,im1.^2-im1.*im2,im2.^2-im1.*im2),[],3));
    
    % Normalize and enhance similarity metric
    out=mat2gray(sim)-mat2gray(dif_c)+1;
    
    % Store results in similarity matrix S
    S(:,b(i,1),b(i,2))=out(:);
end

% Compute minimal local similarity using graph-based connectivity analysis
if size(b,1)>1
    parfor i=1:size(S,1)
        v=squeeze(S(i,:,:)); % Extract similarity values for a given pixel
        v=[v;zeros(1,size(v,2))]; % Add zero padding for stability
        v=v+v'+eye(size(v,1)); % Ensure symmetry and self-identity
        mc(i)=get_min_conn(v); % Compute minimal connectivity
    end
else
    mc=squeeze(S(:,:,2)); % Directly assign similarity map if only one pair
end

% Reshape mc back to 2D format
mc=reshape(mc,[d1,d2]);

% Normalize mean reference image and scale mc accordingly
m=mean(M,2)*mean(M,1);
m=(m./max(m,[],'all')).^(1/4);
mc=m.*mc;
end


function out=get_min_conn(v)
%% get_min_conn: Compute the minimum threshold ensuring full connectivity
%
% Inputs:
%   v - Pairwise similarity matrix
%
% Outputs:
%   out - Minimum threshold ensuring connected graph

% Get the number of frames
 d2=size(v,2);
 
% Define threshold range
 t=linspace(0.1,1,100);
 
% Iterate over threshold values
 for i=1:100
    G = graph(v>t(i)); % Create a graph from the adjacency matrix
    A= conncomp(G); % Compute connected components
    s(i)=length(unique(A)); % Count unique components
    if s(i)>1 % Stop if multiple components exist
        break
    end
 end
 
% Return the minimal threshold ensuring connectivity
 out=t(i);
end
