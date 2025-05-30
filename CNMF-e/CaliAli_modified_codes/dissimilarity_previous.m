function dis=dissimilarity_previous(A1,A2,C1,C2)
%% dissimilarity_previous: Computes the dissimilarity between spatial and temporal components.
%
% Inputs:
%   A1, A2 - Spatial footprints of extracted components (matrices).
%   C1, C2 - Temporal activity traces of extracted components (matrices).
%
% Outputs:
%   dis - A scalar value representing the dissimilarity between previous and updated components.
%
% Usage:
%   dis = dissimilarity_previous(A1, A2, C1, C2);
%
% Description:
%   - Computes similarity matrices for spatial (A1, A2) and temporal (C1, C2) components.
%   - Uses `matchpairs` to find the best one-to-one correspondences between components.
%   - The final dissimilarity score is computed as `1 - mean(sC(ind))`, where `sC` is the similarity matrix for temporal components.
%
% Features:
%   - Employs element-wise multiplication of spatial and temporal similarity matrices.
%   - Uses Hungarian algorithm (`matchpairs`) to maximize the correspondence of components.
%   - Ignores unmatched components in the final calculation.
%
% Notes:
%   - The function relies on `create_similarity_matrix_2` to compute similarity matrices.
%   - A lower dissimilarity score indicates greater similarity between previous and updated components.
%   - If dissimilarity falls below a certain threshold (e.g., 0.05), CNMF-E iterations can be stopped.
%
% Author: Pablo Vergara  
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025

sA=full(create_similarity_matrix_2(A1',A2'));
sC=create_similarity_matrix_2(C1,C2);
s=sA.*sC;
s(isnan(s))=0;
[M,ixz,~] = matchpairs(s,0,'max');

ind = sub2ind([size(s,1) size(s,2)],M(:,1),M(:,2));

%  dis=1-mean([sC(ind);zeros(length(ixz),1)]);
dis=1-mean(sC(ind));

end


