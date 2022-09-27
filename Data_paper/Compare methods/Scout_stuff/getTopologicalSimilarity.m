function T = getTopologicalSimilarity(W,g,m)
% 
% call:
% 
%      T = getTopologicalSimilarity(W,g,m)
%    
%
% Compute the Topological Similarity matrix T from the structural network 
% defined by matrix W. T quantifies how similar are the whole-network influence
% received by two distinct nodes through all paths of every length. It is imple-
% mented as a quantification of the similarity between all pairs of column vectors of 
% the communicability matrix Qexp, and as such can be computed using any n-dimen-
% sional measure of similarity. The present code allows you to choose to compute 
% the topological similarity matrix T using either the (1) cosine similarity, 
% (2) Pearson correlation coefficient or (3) Euclidean distance. Choose the prefer-
% red method having in mind their differences, characteristics and limitations. 
% NOTE: the code calls 'getEucliDist.m'
% 
% 
% INPUT
% 
%        W   :  n-by-n matrix (cab be weighted, unweighted, directed or undirected)
%        g   :  global coupling factor (default is 1)
%        m   :  compute T either using:
%
%               m = 1, cosine similarity (default)
%               m = 2, Pearson Ccrrelation coefficient
%               m = 3, Euclidean distance
%        
% OUTPUT
% 
%        T   : Topological Similarity matrix (n-by-n)
%        
%
% Reference:
% 
% - Bettinardi, R.G., Deco, G., Karlaftis, V.M., Van Hartevelt, T.J., Fernandes, H.M., Kourtzi, Z., Kringelbach, M.L. & Zamora-López, G.
%   (2017). “How structure sculpts function: Unveiling the contribution of anatomical connectivity to the brain's spontaneous
%   correlation structure.” Special Issue: On the relation of dynamics and structure in brain networks. Chaos: An
%   Interdisciplinary Journal of Nonlinear Science, 27(4), 047409. DOI: http://dx.doi.org/10.1063/1.4980099
%
%
% -----------------------------------------------------------------------------------------------------------------
% R.G. Bettinardi
%
% Computational Neuroscience Group, Pompeu Fabra University
% mail: rug.bettinardi@gmail.com
% --------------------------------------------------------------------------------------------------------------------

if ismatrix(W)==0
    error('Input W must have maximum 2 dimensions!')
end

if size(W,1)~=size(W,2)
    error('Input W must be a SQUARE matrix!')
end     

if nargin < 3
    m = 1;
end

n    = size(W,1);
T    = zeros(n);
Qexp = expm(g.*W);   % exponential mapping ("influence" matrix)


% COSINE SIMILARITY of Qexp vectors:
%-----------------------------------
if m == 1
    for i = 1:n
        for j = 1:n
            Qi     = Qexp(:,i);
            Qj     = Qexp(:,j);
            T(i,j) = dot(Qi,Qj) / (norm(Qi) * norm(Qj));
        end
    end
end


% CORRELATION between Qexp vectors:
%-----------------------------------
if m == 2
    T = corr(Qexp);
end
 

% EUCLIDEAN DISTANCE between Qexp vectors:
%----------------------------------------
if m == 3
    for i = 1:n
        for j = 1:n
            Qi     = Qexp(:,i);
            Qj     = Qexp(:,j);          
            T(i,j) = getEucliDist(Qi,Qj);
        end
    end
end


