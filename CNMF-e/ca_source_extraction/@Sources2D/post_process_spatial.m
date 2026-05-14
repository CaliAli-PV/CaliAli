function A_ = post_process_spatial(obj, A_new, ind)
% postprocess spatial components of all neurons

if ~exist('A_new', 'var')
    A_new = obj.reshape(obj.A, 2);
end
if ~exist('ind', 'var') || isempty(ind)
    ind = [];
end

%             A_new = threshold_components(A_new, obj.options);
spatial_constraints = obj.options.spatial_constraints;
circular_shape = spatial_constraints.circular;
connected_shape = spatial_constraints.connected;

[d1, d2, K] = size(A_new);
d = d1*d2;
A_new = reshape(A_new, d, K);
if isempty(ind)
    ind = 1:K;
else
    ind = unique(ind(:))';
end
if isempty(ind)
    A_ = sparse(double(A_new));
    return;
end

Ai = mat2cell(A_new(:, ind), d, ones(1,numel(ind)));

parfor m=1:numel(ind)
    ai = reshape(full(Ai{m}), d1, d2);
    
    % remove isolated pixels
    if connected_shape
        ai = connectivity_constraint(ai);
    end
    
    if circular_shape
        ai = circular_constraints(ai); % assume neuron shapes are spatially convex
    end
    
    Ai{m} = ai(:);
end
A_new(:, ind) = cell2mat(Ai);
A_ = sparse(double(A_new));
end
