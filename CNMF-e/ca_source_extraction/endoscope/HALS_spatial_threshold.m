function A = HALS_spatial_threshold(Y, A, C, active_pixel, maxIter, sn)
%% run HALS by fixating all spatial components 
% input: 
%   Y:  d*T, fluorescence data
%   A:  d*K, spatial components 
%   C:  K*T, temporal components 
%   sn: d*1, noise level for each pixel 
% output: 
%   A: d*K, updated spatial components 

% Author: Pengcheng Zhou, Carnegie Mellon University, adapted from Johannes
% Friedrich's NIPS paper "Fast Constrained Non-negative Matrix
% Factorization for Whole-Brain Calcium Imaging Data

%% options for HALS
if nargin<5;    maxIter = 1;    end;    %maximum iteration number 
if nargin<4;    active_pixel=true(size(A));
elseif isempty(active_pixel)
    active_pixel = true(size(A)); 
else
    active_pixel = logical(active_pixel); 
end;     %determine nonzero pixels 

%% thresholding C 
IND_thresh = bsxfun(@lt, C, 3); 
C_thresh = C; 
C_thresh(IND_thresh) = 0; 

%% initialization 
A(~active_pixel) = 0; 
K = size(A, 2);     % number of components 
U = Y*C_thresh'; 
V = C*C_thresh'; 
cc = sum(C_thresh.^2, 2);   % squares of l2 norm all all components 
%Amin = 4 * bsxfun(@times, sn, 1./sqrt(cc')); 
%% updating 
for miter=1:maxIter
    for k=1:K
        tmp_ind = active_pixel(:, k); 
        ak = max(0, A(tmp_ind, k)+(U(tmp_ind, k)-A(tmp_ind,:)*V(:, k))/cc(k)); 
        A(tmp_ind, k) = ak; 
    end
   % A(A<Amin) = 0; 
end