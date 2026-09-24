function [b, f] = fit_nmf_model(Y, nb, A, C, b_old, f_old, thresh_outlier, sn, ind_patch)
% fit a patched data with NMF
[d, T] = size(Y);
if ~exist('A', 'var') || isempty(A)
    A = ones(d,1); 
    C = zeros(1, T); 
elseif issparse(A)
    A = full(A); 
end
Y = double(Y); 
B = Y - A*C; 
B_old = b_old*f_old;
tmp_B = B(ind_patch, :);
% Only when there is a previous background to compare against, and only when it
% covers the same frames as this patch. On the first pass there is no estimate
% yet, and b_old*f_old is not commensurate with the batch -- comparing them is
% what raised "Non-singleton dimensions of the two input arrays must match each
% other". A single column broadcasts and is fine.
if ~isempty(b_old) && ~isempty(f_old) && ismember(size(B_old,2), [1, size(tmp_B,2)])
    ind_outlier = bsxfun(@gt, tmp_B, bsxfun(@plus, B_old, thresh_outlier*reshape(sn, [], 1)));
    tmp_B(ind_outlier) = B_old(ind_outlier);
    B(ind_patch, :) = tmp_B;
end
clear tmp_B B_old ind_outlier;

% if (norm(sum(b_old(:)))==0) || (norm(sum(f_old(:)))==0)
[b, f] = nnmf(B, nb);
% else
%     [b, f] = nnmf(B, nb, 'w0', b_old, 'h0', f_old);
% end
b = b(ind_patch, :);
