function [b, f, b0] = fit_svd_model(Y, nb, A, C, b_old, f_old, thresh_outlier, sn, ind_patch)
% fit a patched data with SVD
[d, T] = size(Y); 

Ymean = mean(Y,2); 
if ~exist('A', 'var') || isempty(A)
    A = ones(d,1); 
    C = zeros(1, T); 
elseif issparse(A)
    A = full(A); 
end
Cmean = mean(C, 2); 
Y = bsxfun(@minus, double(Y), Ymean); 
C = bsxfun(@minus, C, Cmean);

if ~exist('ind_patch', 'var')
    ind_patch = true(size(A,1), 1); 
end

if nb==0
    b = 0;
    f = 0;
    b0 = Ymean(ind_patch) - A(ind_patch,:)*Cmean-b*mean(f, 2);
    return;
end

Bf = Y - A*C;

% thresho_outlier, with the h in the wrong place, is a variable that has never
% existed, so this block had never run on any recording. Suppressing outliers
% against the previous background is the whole reason b_old and f_old are passed
% in, and with the guard misspelled svd was quietly skipping it.
% Only when there is a previous background to compare against, and only when it
% covers the same frames as this patch. On the first pass there is no estimate
% yet, and b_old*f_old is not commensurate with the batch -- comparing them is
% what raised "Non-singleton dimensions of the two input arrays must match each
% other". A single column broadcasts and is fine.
Bf_old = [];
if ~isempty(b_old) && ~isempty(f_old), Bf_old = b_old*f_old; end
if exist('thresh_outlier','var') && ismember(size(Bf_old,2), [1, size(Bf,2)])
    tmp_Bf = Bf(ind_patch, :);
    ind_outlier = bsxfun(@gt, tmp_Bf, bsxfun(@plus, Bf_old, thresh_outlier*reshape(sn, [], 1)));
    tmp_Bf(ind_outlier) = Bf_old(ind_outlier);
    Bf(ind_patch, :) = tmp_Bf;
    clear tmp_Bf Bf_old ind_outlier;
end

[u, s, v] = svdsecon(bsxfun(@minus, Bf, mean(Bf, 2)), nb); 
b = u(ind_patch, :)*s; 
f = v'; 
b0 = Ymean(ind_patch) - A(ind_patch,:)*Cmean-b*mean(f, 2);

