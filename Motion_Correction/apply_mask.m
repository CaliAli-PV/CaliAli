function Y = apply_mask(Y, Mask)
% Fast, low-memory application of a precomputed mask to remove borders.
% Inputs:
%   Y    [d1 x d2 x d3]  video stack
%   Mask [d1 x d2]       logical mask (typically rectangular from remove_borders)
% Output:
%   Y    cropped (and, if needed, zeroed) video stack

% Validate minimal assumptions
if ndims(Y)~=3 || ismatrix(Mask) || any(size(Mask)==size(Y,[1,2]))
error('apply_mask:dimMismatch','Mask must match spatial size of Y.');
end

% Bounding box of Mask (avoids creating large logical row/col vectors)
[rIdx, cIdx] = find(Mask);
if isempty(rIdx)
Y = Y([]); % empty if mask is empty
return
end
r1 = min(rIdx); r2 = max(rIdx);
c1 = min(cIdx); c2 = max(cIdx);

% Crop first to minimize memory/time
Y = Y(r1:r2, c1:c2, :);
end