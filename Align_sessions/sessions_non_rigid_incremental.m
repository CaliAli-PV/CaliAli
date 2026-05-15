function [P_new, shift_new, incremental_crop_mask] = sessions_non_rigid_incremental(P_reference, P_new, opt, target_mask, neurons_only)
%% sessions_non_rigid_incremental: Estimate target-only non-rigid alignment.
%
% Computes pairwise transforms from the new session to each previous aligned
% session, then combines them with the same local/global weighting style used by
% the standard inter-session non-rigid alignment.

if ~exist('neurons_only', 'var')
    neurons_only = false;
end

if ~opt.do_alignment_non_rigid
    [d1, d2, n_new] = size(P_new.(1){1, 1});
    shift_new = zeros(d1, d2, 2, n_new);
    incremental_crop_mask = true(d1, d2);
    return
end

fprintf(1, 'Calculating pinned target-only non-rigid alignment...\n');
[Proj, n_reference, n_new, P_new] = pre_allocate_incremental_projections(P_reference, P_new, opt, neurons_only);
[coeff, T, locW, globW] = get_target_matrices(Proj, n_reference, n_new);
W = combine_weights(locW, globW);

shift_new = solve_pinned_shifts(coeff, T, W, n_new);
shift_new(isnan(shift_new)) = 0;

for k = 1:min(4, size(P_new, 2))
    temp = double(cell2mat(P_new{1, k}));
    for i = 1:n_new
        temp(:, :, i) = imwarp(temp(:, :, i), shift_new(:, :, :, i), 'FillValues', nan);
    end
    P_new{1, k} = {apply_alignment_mask_to_stack(temp, target_mask)};
end

crop_source = min(4, size(P_new, 2));
valid = 1 - max(isnan(P_new.(crop_source){1, 1}), [], 3);
[~, incremental_crop_mask] = remove_borders(valid, 0);
for k = 1:min(4, size(P_new, 2))
    P_new{1, k} = {crop_stack_by_mask(P_new.(k){1, 1}, incremental_crop_mask)};
end
P_new.(5){1, 1} = [];
end

function [Proj, n_reference, n_new, P_new] = pre_allocate_incremental_projections(P_reference, P_new, opt, neurons_only)
n_new = size(P_new.(1){1, 1}, 3);
P_all = concatenate_projection_tables(P_reference, P_new);

Mb = v2uint8(cell2mat(P_all{1, 1}));
Vf = v2uint8(cell2mat(P_all{1, 2}));
Cn = cell2mat(P_all{1, 3});
PNR = cell2mat(P_all{1, 4});

Cn = v2uint8(mat2gray(PNR) .* mat2gray(Cn).^2);
for i = 1:size(Cn, 3)
    Cn(:, :, i) = adapthisteq(Cn(:, :, i));
end

if ~contains(opt.projections, 'BV') || neurons_only
    Vf = Cn;
end
if ~contains(opt.projections, 'neuron')
    Cn = Vf;
end

X = zeros(size(Cn));
for i = 1:size(Cn, 3)
    X(:, :, i) = mat2gray(max(cat(3, Vf(:, :, i), medfilt2(Cn(:, :, i))), [], 3));
end
X = v2uint8(X);

Proj_t = permute(cat(4, Mb, Cn, X, Vf, Vf), [1, 2, 4, 3]);
[d1, d2, d3, d4] = size(Proj_t);
Proj_t = squeeze(mat2cell(Proj_t, d1, d2, d3, ones(1, d4)));

n_reference = d4 - n_new;
Proj = cell(d4, 1);
for i = 1:d4
    Proj{i, 1} = Proj_t{i};
end
clear Proj_t;
end

function out = concatenate_projection_tables(P_reference, P_new)
out = P_reference;
for i = 1:min(4, size(P_reference, 2))
    ref_value = P_reference.(i){1, 1};
    new_value = P_new.(i){1, 1};
    if size(ref_value, 1) ~= size(new_value, 1) || size(ref_value, 2) ~= size(new_value, 2)
        error('CaliAli:IncrementalAlignmentSizeMismatch', ...
            ['Incremental non-rigid alignment requires the new translated projection ', ...
            'size to match the previous translated reference size. Found [%d %d] and [%d %d].'], ...
            size(ref_value, 1), size(ref_value, 2), size(new_value, 1), size(new_value, 2));
    end
    out.(i){1, 1} = cat(3, ref_value, new_value);
end
end

function [coeff, T, locW, globW] = get_target_matrices(Proj, n_reference, n_new)
n_new_pairs = n_new * (n_new - 1) / 2;
n_pair_calculations = n_reference * n_new + n_new_pairs;
pair_nodes = zeros(n_pair_calculations, 2);
pair_is_old_new = false(n_pair_calculations, 1);
row = 0;

for old_ix = 1:n_reference
    for new_ix = 1:n_new
        row = row + 1;
        pair_nodes(row, :) = [old_ix, n_reference + new_ix];
        pair_is_old_new(row) = true;
    end
end

for new_a = 1:n_new - 1
    for new_b = new_a + 1:n_new
        row = row + 1;
        pair_nodes(row, :) = [n_reference + new_a, n_reference + new_b];
    end
end

pair_results = cell(n_pair_calculations, 1);
proj_first = Proj(pair_nodes(:, 1));
proj_second = Proj(pair_nodes(:, 2));
parfor pair_ix = 1:n_pair_calculations
    [t_T, t_loc_c, t_glob_c, t_Tb, t_loc_cb, t_glob_cb] = ...
        get_transformations(proj_first{pair_ix}, proj_second{pair_ix});
    pair_results{pair_ix} = {t_T, t_loc_c, t_glob_c, t_Tb, t_loc_cb, t_glob_cb};
end

n_edges = n_reference * n_new + 2 * n_new_pairs;
coeff = zeros(n_edges, n_new);
T = cell(n_edges, 1);
globW = zeros(n_edges, 1);
loc_temp = cell(n_edges, 1);
edge_ix = 0;

for pair_ix = 1:n_pair_calculations
    result = pair_results{pair_ix};
    if pair_is_old_new(pair_ix)
        new_ix = pair_nodes(pair_ix, 2) - n_reference;
        edge_ix = edge_ix + 1;
        coeff(edge_ix, new_ix) = 1;
        T{edge_ix} = result{4};
        loc_temp{edge_ix} = result{2};
        globW(edge_ix, 1) = result{3};
    else
        new_a = pair_nodes(pair_ix, 1) - n_reference;
        new_b = pair_nodes(pair_ix, 2) - n_reference;

        edge_ix = edge_ix + 1;
        coeff(edge_ix, new_a) = 1;
        coeff(edge_ix, new_b) = -1;
        T{edge_ix} = result{1};
        loc_temp{edge_ix} = result{2};
        globW(edge_ix, 1) = result{3};

        edge_ix = edge_ix + 1;
        coeff(edge_ix, new_b) = 1;
        coeff(edge_ix, new_a) = -1;
        T{edge_ix} = result{4};
        loc_temp{edge_ix} = result{5};
        globW(edge_ix, 1) = result{6};
    end
end

locW = zeros([size(loc_temp{1}), n_edges]);
for i = 1:n_edges
    locW(:, :, i) = loc_temp{i};
end
end

function W = combine_weights(locW, globW)
n_edges = size(locW, 3);
if n_edges == 1
    W = ones(size(locW));
    return
end

globW(~isfinite(globW)) = 0;
if sum(globW) == 0
    globW = ones(size(globW)) ./ numel(globW);
else
    globW = globW ./ sum(globW);
end

locW(~isfinite(locW)) = 0;
den = sum(locW, 3);
den(den == 0) = 1;
X = locW ./ den;

for i = 1:n_edges
    X(:, :, i) = imgaussfilt(X(:, :, i), 8, 'FilterSize', 91);
end

X = mat2gray(X);
den = sum(X, 3);
den(den == 0) = 1;
locW = X ./ den;
if n_edges == 2
    locW = locW * 0 + 0.5;
end

W = zeros(size(locW));
for i = 1:n_edges
    W(:, :, i) = locW(:, :, i) .* globW(i);
end
den = sum(W, 3);
den(den == 0) = 1;
W = W ./ den;
end

function shift_new = solve_pinned_shifts(coeff, T, W, n_new)
[d1, d2, ~] = size(T{1});
n_edges = numel(T);
shift_new = zeros(d1, d2, 2, n_new);

if n_new == 1
    for edge_ix = 1:n_edges
        weight = cat(3, W(:, :, edge_ix), W(:, :, edge_ix));
        shift_new(:, :, :, 1) = shift_new(:, :, :, 1) + T{edge_ix} .* weight;
    end
    return
end

T_stack = zeros(d1, d2, 2, n_edges);
for edge_ix = 1:n_edges
    T_stack(:, :, :, edge_ix) = T{edge_ix};
end

for row = 1:d1
    for col = 1:d2
        weights = squeeze(W(row, col, :));
        lhs = coeff' * (coeff .* weights);
        if rcond(lhs) < eps
            lhs = lhs + eye(n_new) * eps;
        end
        for dim = 1:2
            rhs = coeff' * (weights .* squeeze(T_stack(row, col, dim, :)));
            shift_new(row, col, dim, :) = lhs \ rhs;
        end
    end
end
end

function stack = apply_alignment_mask_to_stack(stack, mask)
if isempty(mask)
    return
end
if size(stack, 1) ~= size(mask, 1) || size(stack, 2) ~= size(mask, 2)
    error('CaliAli:IncrementalAlignmentSizeMismatch', ...
        'Projection stack and non-rigid alignment mask sizes do not match.');
end
f1 = max(sum(mask, 1));
f2 = max(sum(mask, 2));
stack = reshape(stack, size(stack, 1) * size(stack, 2), []);
stack = stack(logical(mask), :);
stack = reshape(stack, f1, f2, []);
end

function stack = crop_stack_by_mask(stack, mask)
if isempty(mask)
    return
end
if size(stack, 1) ~= size(mask, 1) || size(stack, 2) ~= size(mask, 2)
    error('CaliAli:IncrementalAlignmentSizeMismatch', ...
        'Projection stack and incremental crop mask sizes do not match.');
end
f1 = max(sum(mask, 1));
f2 = max(sum(mask, 2));
stack = reshape(stack, size(stack, 1) * size(stack, 2), []);
stack = stack(logical(mask), :);
stack = reshape(stack, f1, f2, []);
end

function [T, loc_c, glob_c, Tb, loc_cb, glob_cb, fwa, bwa] = get_transformations(M1, M2)
plotme = 0;
opt{1, 1} = struct('stop_criterium', 0.001, 'imagepad', 1.5, 'niter', 100, 'sigma_fluid', 1, ...
    'sigma_diffusion', 3, 'sigma_i', 1, 'sigma_x', 1, 'do_display', plotme, 'do_plotenergy', plotme);
opt{2, 1} = struct('stop_criterium', 0.001, 'imagepad', 1.5, 'niter', 100, 'sigma_fluid', 1, ...
    'sigma_diffusion', 4, 'sigma_i', 1, 'sigma_x', 1, 'do_display', plotme, 'do_plotenergy', plotme);
opt{3, 1} = struct('stop_criterium', 0.001, 'imagepad', 1.5, 'niter', 100, 'sigma_fluid', 3, ...
    'sigma_diffusion', 3, 'sigma_i', 1, 'sigma_x', 1, 'do_display', plotme, 'do_plotenergy', plotme);
opt{4, 1} = struct('stop_criterium', 0.001, 'imagepad', 1.5, 'niter', 20, 'sigma_fluid', 3, ...
    'sigma_diffusion', 3, 'sigma_i', 1, 'sigma_x', 2, 'do_display', plotme, 'do_plotenergy', plotme);

Mb = M1(:, :, 1);
M1(:, :, 1) = [];
M2(:, :, 1) = [];

[im1, im2, T] = MR_Log_demon(M1, M2, opt);
fwa = cat(4, im1(:, :, 1:3), im2(:, :, 1:3));
loc_c = get_local_corr_Vf(cat(3, double(im1(:, :, 2)), double(im2(:, :, 2))), Mb);
t1v = im1(:, :, 2);
t2v = im2(:, :, 2);
glob_c = 1 - pdist([double(t1v(:)'); double(t2v(:)')], 'correlation');
T = squeeze(-T);

[im1, im2, Tb] = MR_Log_demon(M2, M1, opt);
bwa = cat(4, im1(:, :, 1:3), im2(:, :, 1:3));
loc_cb = get_local_corr_Vf(cat(3, double(im1(:, :, 2)), double(im2(:, :, 2))), Mb);
t1v = im1(:, :, end);
t2v = im2(:, :, end);
glob_cb = 1 - pdist([double(t1v(:)'); double(t2v(:)')], 'correlation');
Tb = squeeze(-Tb);
end
