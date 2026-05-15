function [P_new, T_new] = sessions_translate_incremental(P_reference, P_new, opt, target_mask)
%% sessions_translate_incremental: Estimate pinned translations for new sessions.
%
% The reference projections are kept fixed. New session shifts are solved from
% old-vs-new and new-vs-new pairwise translation constraints.

if contains(opt.projections, 'BV')
    ref = cell2mat(P_reference{1, 2});
    new_ref = cell2mat(P_new{1, 2});
else
    ref = cell2mat(P_reference{1, 3});
    new_ref = cell2mat(P_new{1, 3});
end

validate_spatial_match(ref, new_ref);
all_ref = mat2gray(cat(3, ref, new_ref));
[d1, d2, ~] = size(all_ref);
n_reference = size(ref, 3);
n_new = size(new_ref, 3);
bound1 = 20;
bound2 = 20;

if ~opt.do_alignment_translation
    T_new = zeros(n_new, 2);
    return
end

fprintf(1, 'Aligning new sessions by pinned pairwise translation ...\n');
options_r = NoRMCorreSetParms('d1', d1 - bound1, 'init_batch', 1, ...
    'd2', d2 - bound2, 'bin_width', 2, 'max_shift', [1000, 1000, 1000], ...
    'iter', 5, 'correct_bidir', false, 'shifts_method', 'fft', 'boundary', 'NaN');

old_new_T = zeros(n_reference, n_new, 2);
for i = 1:n_reference
    for j = 1:n_new
        old_new_T(i, j, :) = estimate_pair_translation(all_ref(:, :, i), ...
            all_ref(:, :, n_reference + j), options_r, bound1, bound2);
    end
end

new_new_T = zeros(n_new, n_new, 2);
for i = 1:n_new - 1
    for j = i + 1:n_new
        new_new_T(i, j, :) = estimate_pair_translation( ...
            all_ref(:, :, n_reference + i), all_ref(:, :, n_reference + j), ...
            options_r, bound1, bound2);
    end
end

T_new = solve_pinned_translations(old_new_T, new_new_T);

for i = 1:min(4, size(P_new, 2))
    temp = cell2mat(P_new{1, i});
    for j = 1:n_new
        temp(:, :, j) = imtranslate(temp(:, :, j), T_new(j, :));
    end
    P_new{1, i} = {apply_alignment_mask_to_stack(temp, target_mask)};
end
P_new = scale_Cn_incremental(P_new);
end

function T = estimate_pair_translation(reference_image, moving_image, options_r, bound1, bound2)
pair_ref = cat(3, reference_image, moving_image);
[~, shifts, ~] = normcorre_batch(pair_ref(bound1/2+1:end-bound1/2, ...
    bound2/2+1:end-bound2/2, :), options_r);
pair_shift = shifts(2).shifts - shifts(1).shifts;
T = flip(squeeze(pair_shift)');
end

function T_new = solve_pinned_translations(old_new_T, new_new_T)
[n_reference, n_new, ~] = size(old_new_T);
n_edges = n_reference * n_new + n_new * (n_new - 1) / 2;
A = zeros(n_edges, n_new);
B = zeros(n_edges, 2);
row = 0;

for old_ix = 1:n_reference
    for new_ix = 1:n_new
        row = row + 1;
        A(row, new_ix) = 1;
        B(row, :) = squeeze(old_new_T(old_ix, new_ix, :))';
    end
end

for new_a = 1:n_new - 1
    for new_b = new_a + 1:n_new
        row = row + 1;
        A(row, new_a) = -1;
        A(row, new_b) = 1;
        B(row, :) = squeeze(new_new_T(new_a, new_b, :))';
    end
end

T_new = zeros(n_new, 2);
for dim = 1:2
    T_new(:, dim) = A \ B(:, dim);
end
end

function validate_spatial_match(reference_stack, new_stack)
if size(reference_stack, 1) ~= size(new_stack, 1) || size(reference_stack, 2) ~= size(new_stack, 2)
    error('CaliAli:IncrementalAlignmentSizeMismatch', ...
        ['Incremental translation requires the new session projection size ', ...
        'to match the previous Original projection size. Found [%d %d] and [%d %d].'], ...
        size(reference_stack, 1), size(reference_stack, 2), size(new_stack, 1), size(new_stack, 2));
end
end

function stack = apply_alignment_mask_to_stack(stack, mask)
if isempty(mask)
    return
end
if size(stack, 1) ~= size(mask, 1) || size(stack, 2) ~= size(mask, 2)
    error('CaliAli:IncrementalAlignmentSizeMismatch', ...
        'Projection stack and alignment mask sizes do not match.');
end
f1 = max(sum(mask, 1));
f2 = max(sum(mask, 2));
stack = reshape(stack, size(stack, 1) * size(stack, 2), []);
stack = stack(logical(mask), :);
stack = reshape(stack, f1, f2, []);
end

function P = scale_Cn_incremental(P)
C = v2uint8(mat2gray(P.(3){1, 1}));
ref = v2uint8(P.(2){1, 1});
X = uint8([]);
for k = 1:size(C, 3)
    X(:, :, :, k) = imfuse(C(:, :, k), ref(:, :, k), ...
        'Scaling', 'joint', 'ColorChannels', [1 2 0]);
end
P.(5){1, 1} = X;
end
