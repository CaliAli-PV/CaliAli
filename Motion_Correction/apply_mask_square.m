function Y = apply_mask_square(Y, Mask)
% Apply a precomputed mask to video data without cropping
% Inputs:
%   Y    [d1 x d2 x d3]  video stack
%   Mask [d1 x d2]       logical mask
% Output:
%   Y    same size as input, but with Mask==0 regions set to 0

% Validate dimensions
if ndims(Y) ~= 3 || any(size(Mask) ~= size(Y,1:2))
    error('apply_mask:dimMismatch','Mask must match spatial size of Y.');
end

% Expand mask once across frames
Mask3D = repmat(Mask, [1 1 size(Y,3)]);

% Zero out invalid regions
Y = Y .* cast(Mask3D, 'like', Y);

end