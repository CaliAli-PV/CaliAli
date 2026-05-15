function [neuron]=propagate_spatials(in,ref)

neuron = Sources2D();
CaliAli_options=CaliAli_load(in,'CaliAli_options');
pars=CaliAli_options.cnmf;
neuron = fill_neuron(neuron, pars);
neuron.options = fill_neuron(neuron.options, pars);
neuron.CaliAli_options=CaliAli_options;
neuron.select_data(in);
neuron.getReady();

evalin( 'base', 'clearvars  filePath fileName mat_*' );


re=load(ref,'neuron');
total_F=sum(neuron.CaliAli_options.inter_session_alignment.F);
prev_F=size(re.neuron.C,2);
incremental_mask = get_incremental_mask(CaliAli_options, re.neuron, neuron);
if isempty(incremental_mask)
    neuron.A = re.neuron.A;
else
    target_pixels = neuron.options.d1 * neuron.options.d2;
    neuron.A = crop_spatial_matrix(re.neuron.A, incremental_mask, target_pixels, 'neuron.A');
end
K = size(neuron.A, 2);

% folders and files for saving the results
tmp_dir = sprintf('%s%sframes_%d_%d%s', fileparts(neuron.P.mat_file),filesep, 1, total_F, filesep);
if ~exist(tmp_dir, 'dir')
    mkdir(tmp_dir);
end
log_folder = [tmp_dir,  'LOGS_', get_date(), filesep];
log_file = [log_folder, 'logs.txt'];
log_data_file = [log_folder, 'intermediate_results.mat'];
neuron.P.log_folder = log_folder;
neuron.P.log_file = log_file;
neuron.P.log_data = log_data_file;
mkdir(log_folder);

neuron.C=zeros(K,total_F);
neuron.C_raw=nan(K,total_F);
neuron.S=sparse(K,total_F);

neuron.C(:,1:prev_F) = re.neuron.C;
neuron.C_raw(:,1:prev_F) = re.neuron.C_raw;
neuron.S(:,1:prev_F) = sparse(re.neuron.S);
neuron.C_prev=neuron.C;
neuron.A_prev=neuron.A;

if isempty(incremental_mask)
    neuron.W = re.neuron.W;
    neuron.b0 = re.neuron.b0;
    neuron.b=re.neuron.b;
    neuron.f=re.neuron.f;
    neuron.P.Ymean=re.neuron.P.Ymean;
else
    [neuron.W, neuron.b0, neuron.b, neuron.f, neuron.b0_new, neuron.P.Ymean] = ...
        resize_incremental_spatial_state(re.neuron, neuron, incremental_mask, total_F);
end
neuron.frame_range=[1,total_F];

neuron.P.k_ids = K;
neuron.ids = (1:K);
neuron.tags = zeros(K,1, 'like', uint16(0));

neuron=update_temporal_CaliAli_targeted(neuron,neuron.use_parallel);
neuron=update_residual_Cn_PNR_batch_targeted(neuron,prev_F);
end

function incremental_mask = get_incremental_mask(CaliAli_options, ref_neuron, neuron)
incremental_mask = [];
if ~isfield(CaliAli_options, 'inter_session_alignment')
    return
end
opt = CaliAli_options.inter_session_alignment;
if ~isfield(opt, 'incremental') || ~opt.incremental
    return
end
if ~isfield(opt, 'incremental_mask') || isempty(opt.incremental_mask)
    warning('CaliAli:MissingIncrementalMask', ...
        ['Incremental extraction was requested, but incremental_mask is empty. ', ...
        'Spatial components will be propagated without resizing.']);
    return
end

incremental_mask = logical(opt.incremental_mask);
ref_pixels = size(ref_neuron.A, 1);
if numel(incremental_mask) ~= ref_pixels
    error('CaliAli:InvalidIncrementalMask', ...
        ['incremental_mask has %d pixels, but the reference spatial components ', ...
        'contain %d pixels.'], numel(incremental_mask), ref_pixels);
end

target_pixels = neuron.options.d1 * neuron.options.d2;
if nnz(incremental_mask) ~= target_pixels
    error('CaliAli:InvalidIncrementalMask', ...
        ['incremental_mask keeps %d pixels, but the incremental aligned movie ', ...
        'contains %d pixels.'], nnz(incremental_mask), target_pixels);
end

fprintf(['Applying incremental_mask to propagated spatial components ', ...
    '(%d reference pixels -> %d output pixels).\n'], ...
    numel(incremental_mask), target_pixels);
end

function [W, b0, b, f, b0_new, Ymean] = resize_incremental_spatial_state(ref_neuron, neuron, mask, total_F)
target_dims = [neuron.options.d1, neuron.options.d2];
bg_model = neuron.options.background_model;
Ymean = crop_ymean(ref_neuron.P.Ymean, mask, target_dims);

if strcmpi(bg_model, 'ring')
    W = build_ring_background_weights(neuron);
    b0_full = reference_patch_cells_to_image(ref_neuron.b0, ref_neuron, size(mask), 1, 'b0');
    b0_crop = crop_spatial_value(b0_full, mask, target_dims, 'b0');
    b0 = image_to_patch_cells(b0_crop, neuron);
    b = empty_patch_cells(neuron);
    f = empty_patch_cells(neuron);
else
    W = empty_patch_cells(neuron);
    b = resize_patch_spatial_cells(ref_neuron.b, ref_neuron, neuron, mask, 'b');
    f = resize_patch_temporal_cells(ref_neuron.f, ref_neuron, neuron, mask, total_F);
    if strcmpi(bg_model, 'nmf')
        b0 = empty_patch_cells(neuron);
    else
        b0_full = reference_patch_cells_to_image(ref_neuron.b0, ref_neuron, size(mask), 1, 'b0');
        b0_crop = crop_spatial_value(b0_full, mask, target_dims, 'b0');
        b0 = image_to_patch_cells(b0_crop, neuron);
    end
end

if has_field_or_prop(ref_neuron, 'b0_new') && ~isempty(ref_neuron.b0_new)
    b0_new = crop_spatial_value(ref_neuron.b0_new, mask, target_dims, 'b0_new');
else
    b0_new = zeros(target_dims);
end
end

function A = crop_spatial_matrix(A, mask, target_pixels, field_name)
if isempty(A)
    return
end
mask = mask(:);
if size(A, 1) == numel(mask)
    A = A(mask, :);
elseif size(A, 1) ~= target_pixels
    error('CaliAli:SpatialSizeMismatch', ...
        '%s has %d spatial rows; expected %d reference rows or %d output rows.', ...
        field_name, size(A, 1), numel(mask), target_pixels);
end
end

function value = crop_spatial_value(value, mask, target_dims, field_name)
if isempty(value)
    return
end
old_dims = size(mask);
target_pixels = prod(target_dims);

if iscell(value)
    for i = 1:numel(value)
        value{i} = crop_spatial_value(value{i}, mask, target_dims, field_name);
    end
    return
end

if isnumeric(value) || islogical(value)
    if isequal(size(value, 1), old_dims(1)) && isequal(size(value, 2), old_dims(2))
        trailing_dims = size(value);
        if numel(trailing_dims) < 3
            trailing_dims = [trailing_dims, 1];
        end
        n_planes = prod(trailing_dims(3:end));
        value = reshape(value, old_dims(1), old_dims(2), n_planes);
        cropped = zeros([target_dims, n_planes], 'like', value);
        for i = 1:n_planes
            plane = value(:, :, i);
            cropped(:, :, i) = reshape(plane(mask), target_dims);
        end
        if n_planes == 1
            value = cropped(:, :, 1);
        else
            value = reshape(cropped, [target_dims, trailing_dims(3:end)]);
        end
    elseif isvector(value) && numel(value) == numel(mask)
        value = reshape(value, old_dims);
        value = crop_spatial_value(value, mask, target_dims, field_name);
    elseif ismatrix(value) && size(value, 1) == numel(mask)
        value = crop_spatial_matrix(value, mask, target_pixels, field_name);
    elseif numel(value) ~= target_pixels && size(value, 1) ~= target_pixels
        error('CaliAli:SpatialSizeMismatch', ...
            '%s does not match the reference or incremental spatial size.', field_name);
    end
end
end

function Ymean = crop_ymean(Ymean, mask, target_dims)
if isempty(Ymean)
    return
end
if iscell(Ymean)
    for i = 1:numel(Ymean)
        Ymean{i} = crop_spatial_value(Ymean{i}, mask, target_dims, 'P.Ymean');
    end
else
    Ymean = crop_spatial_value(Ymean, mask, target_dims, 'P.Ymean');
end
end

function W = build_ring_background_weights(neuron)
mat_data = neuron.P.mat_data;
patch_pos = mat_data.patch_pos;
block_pos = mat_data.block_pos;
d1 = neuron.options.d1;
d2 = neuron.options.d2;
bg_ssub = neuron.options.bg_ssub;
rr = ceil(neuron.options.ring_radius / bg_ssub);
[r_shift, c_shift] = get_nhood(rr, neuron.options.num_neighbors);
W = cell(size(patch_pos));

for mpatch = 1:numel(patch_pos)
    tmp_patch = patch_pos{mpatch};
    tmp_block = block_pos{mpatch};
    nr = diff(tmp_patch(1:2)) + 1;
    nc = diff(tmp_patch(3:4)) + 1;
    nr_block = diff(tmp_block(1:2)) + 1;
    nc_block = diff(tmp_block(3:4)) + 1;

    if bg_ssub == 1
        [csub, rsub] = meshgrid(tmp_patch(3):tmp_patch(4), tmp_patch(1):tmp_patch(2));
        csub = reshape(csub, [], 1);
        rsub = reshape(rsub, [], 1);
        ii = repmat((1:numel(csub))', [1, length(r_shift)]);
        csub = bsxfun(@plus, csub, c_shift);
        rsub = bsxfun(@plus, rsub, r_shift);
        ind = and(and(csub >= 1, csub <= d2), and(rsub >= 1, rsub <= d1));
        jj = (csub - tmp_block(3)) * nr_block + (rsub - tmp_block(1) + 1);
        temp = sparse(ii(ind), jj(ind), 1, nr * nc, nr_block * nc_block);
    else
        d1s = ceil(nr_block / bg_ssub);
        d2s = ceil(nc_block / bg_ssub);
        [csub, rsub] = meshgrid(1:d2s, 1:d1s);
        csub = reshape(csub, [], 1);
        rsub = reshape(rsub, [], 1);
        ii = repmat((1:numel(csub))', [1, length(r_shift)]);
        csub = bsxfun(@plus, csub, c_shift);
        rsub = bsxfun(@plus, rsub, r_shift);
        jj = (csub - 1) * d1s + rsub;
        ind = and(and(csub >= 1, csub <= d2s), and(rsub >= 1, rsub <= d1s));
        temp = sparse(ii(ind), jj(ind), 1, d1s * d2s, d1s * d2s);
    end
    row_sum = full(sum(temp, 2));
    row_sum(row_sum == 0) = 1;
    W{mpatch} = bsxfun(@times, temp, 1 ./ row_sum);
end
end

function cells = empty_patch_cells(neuron)
cells = cell(size(neuron.P.mat_data.patch_pos));
end

function cells = image_to_patch_cells(image_stack, neuron)
patch_pos = neuron.P.mat_data.patch_pos;
cells = cell(size(patch_pos));
if ismatrix(image_stack)
    image_stack = reshape(image_stack, size(image_stack, 1), size(image_stack, 2), 1);
end
n_planes = size(image_stack, 3);
for mpatch = 1:numel(patch_pos)
    tmp_patch = patch_pos{mpatch};
    patch = image_stack(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4), :);
    cells{mpatch} = reshape(patch, [], n_planes);
end
end

function image_stack = reference_patch_cells_to_image(cells, ref_neuron, old_dims, default_planes, field_name)
if isempty(cells)
    image_stack = zeros([old_dims, default_planes]);
    return
end
if ~iscell(cells)
    if (isnumeric(cells) || islogical(cells)) && ...
            isequal(size(cells, 1), old_dims(1)) && isequal(size(cells, 2), old_dims(2))
        image_stack = cells;
    elseif (isnumeric(cells) || islogical(cells)) && ismatrix(cells) && size(cells, 1) == prod(old_dims)
        n_planes = size(cells, 2);
        image_stack = zeros([old_dims, n_planes], 'like', cells);
        for i = 1:n_planes
            image_stack(:, :, i) = reshape(cells(:, i), old_dims);
        end
    else
        image_stack = crop_spatial_value(cells, true(old_dims), old_dims, field_name);
    end
    return
end

patch_pos = ref_neuron.P.mat_data.patch_pos;
sample_idx = find(~cellfun(@isempty, cells), 1);
if isempty(sample_idx)
    image_stack = zeros([old_dims, default_planes]);
    return
end
sample = cells{sample_idx};
if isvector(sample)
    n_planes = 1;
else
    n_planes = size(sample, 2);
end
image_stack = zeros([old_dims, n_planes], 'like', sample);

for mpatch = 1:min(numel(patch_pos), numel(cells))
    if isempty(cells{mpatch})
        continue
    end
    tmp_patch = patch_pos{mpatch};
    nr = diff(tmp_patch(1:2)) + 1;
    nc = diff(tmp_patch(3:4)) + 1;
    patch = reshape(cells{mpatch}, nr, nc, []);
    image_stack(tmp_patch(1):tmp_patch(2), tmp_patch(3):tmp_patch(4), :) = patch;
end
end

function b = resize_patch_spatial_cells(b_ref, ref_neuron, neuron, mask, field_name)
if isempty(b_ref)
    b = empty_patch_cells(neuron);
    return
end
old_image = reference_patch_cells_to_image(b_ref, ref_neuron, size(mask), 1, field_name);
new_image = crop_spatial_value(old_image, mask, [neuron.options.d1, neuron.options.d2], field_name);
b = image_to_patch_cells(new_image, neuron);
end

function f = resize_patch_temporal_cells(f_ref, ref_neuron, neuron, mask, total_F)
target_patch_pos = neuron.P.mat_data.patch_pos;
ref_patch_pos = ref_neuron.P.mat_data.patch_pos;
f = cell(size(target_patch_pos));
if isempty(f_ref) || ~iscell(f_ref)
    return
end
[kept_rows, kept_cols] = kept_mask_indices(mask);
for mpatch = 1:numel(target_patch_pos)
    tmp_patch = target_patch_pos{mpatch};
    center_row = round(mean(tmp_patch(1:2)));
    center_col = round(mean(tmp_patch(3:4)));
    ref_row = kept_rows(center_row);
    ref_col = kept_cols(center_col);
    ref_idx = find_patch_containing(ref_patch_pos, ref_row, ref_col);
    if isempty(ref_idx) || isempty(f_ref{ref_idx})
        f{mpatch} = [];
    else
        f{mpatch} = pad_temporal_background(f_ref{ref_idx}, total_F);
    end
end
end

function [rows, cols] = kept_mask_indices(mask)
[row_idx, col_idx] = find(mask);
rows = unique(row_idx);
cols = unique(col_idx);
end

function idx = find_patch_containing(patch_pos, row, col)
idx = [];
for i = 1:numel(patch_pos)
    pos = patch_pos{i};
    if row >= pos(1) && row <= pos(2) && col >= pos(3) && col <= pos(4)
        idx = i;
        return
    end
end
end

function f = pad_temporal_background(f, total_F)
if isempty(f) || size(f, 2) >= total_F
    return
end
if size(f, 2) == 0
    f(:, total_F) = 0;
else
    f(:, end+1:total_F) = repmat(f(:, end), 1, total_F - size(f, 2));
end
end

function tf = has_field_or_prop(value, name)
if isstruct(value)
    tf = isfield(value, name);
else
    tf = isprop(value, name);
end
end

















