function CaliAli_options = run_incremental_alignment(user_options, mode)
%% run_incremental_alignment: Append new sessions to a completed alignment.

reference_file = mode.reference_aligned_file;
new_input_files = mode.new_input_files;
if isempty(new_input_files)
    new_input_files = {mode.new_input_file};
end
new_input_files = normalize_new_input_files(new_input_files);
out_file = get_incremental_aligned_output_file(new_input_files);

if ~is_completed_alignment_file(reference_file)
    error('CaliAli:IncrementalAlignmentReference', ...
        'The incremental alignment reference must be a completed *_Aligned.mat file: %s', reference_file);
end

original_options = CaliAli_load(reference_file, 'CaliAli_options');
original_opt = original_options.inter_session_alignment;
if ~isfield(original_opt, 'P') || isempty(original_opt.P)
    error('CaliAli:IncrementalAlignmentReference', ...
        'The reference aligned file does not contain saved inter-session projections.');
end
warn_incremental_option_mismatches(user_options, original_options);

if is_completed_alignment_file(out_file)
    completed_status = get_completed_output_status(out_file, reference_file, new_input_files);
    if strcmp(completed_status, 'match')
        fprintf(1, 'File with name "%s" already exists.\n', out_file);
        try
            CaliAli_options = CaliAli_load(out_file, 'CaliAli_options');
        catch
            CaliAli_options = user_options;
            CaliAli_options.inter_session_alignment.out_aligned_sessions = out_file;
        end
        return
    elseif strcmp(completed_status, 'legacy')
        warning('CaliAli:IncrementalAlignment:legacyOutput', ...
            'Found completed incremental output without incremental crop metadata. Recomputing...');
        delete(out_file);
    else
        error('CaliAli:IncrementalAlignmentOutputConflict', ...
            ['Completed output file "%s" already exists, but its incremental metadata ', ...
            'does not match the requested reference/new-session inputs. Delete or rename ', ...
            'the existing output before running this different incremental alignment.'], out_file);
    end
elseif isfile(out_file)
    warning('CaliAli:IncrementalAlignment:incompleteFile', ...
        'Found incomplete incremental aligned file. Recomputing...');
    delete(out_file);
end

new_session_options = prepare_incremental_processing_options(original_options, new_input_files);
new_session_options = remove_invalid_incremental_detrend_outputs(new_session_options);
new_session_options = record_input_frame_counts(new_session_options);
new_session_options = detrend_batch_and_calculate_projections(new_session_options);
new_session_options = verify_detrended_outputs(new_session_options);
new_session_options.inter_session_alignment.out_aligned_sessions = out_file;

P_new_original = get_stored_projections(new_session_options);
new_det_ranges = load_new_det_ranges(new_session_options.inter_session_alignment.output_files);

[opt, P] = calculate_incremental_alignment(original_opt, new_session_options.inter_session_alignment, ...
    P_new_original, reference_file, new_input_files, out_file);

CaliAli_options = original_options;
CaliAli_options.inter_session_alignment = opt;
CaliAli_options.inter_session_alignment.P = P;
CaliAli_options.inter_session_alignment.alignment_metrics = get_alignment_metrics(P);
CaliAli_options.inter_session_alignment.Cn = max(P.(size(P, 2))(1, :).(3){1, 1}, [], 3);
CaliAli_options.inter_session_alignment.Cn_scale = max(CaliAli_options.inter_session_alignment.Cn, [], 'all');
CaliAli_options.inter_session_alignment.Cn = CaliAli_options.inter_session_alignment.Cn ./ ...
    CaliAli_options.inter_session_alignment.Cn_scale;
CaliAli_options.inter_session_alignment.PNR = max(P.(size(P, 2))(1, :).(4){1, 1}, [], 3);
CaliAli_options.inter_session_alignment.incremental_alignment.new_det_range = new_det_ranges;

CaliAli_options = apply_incremental_transformations(CaliAli_options, reference_file, ...
    new_session_options.inter_session_alignment.input_files);

save_relevant_variables(CaliAli_options);
end

function tf = is_completed_alignment_file(path)
tf = false;
if ~isfile(path)
    return
end
try
    tf = logical(CaliAli_load(path, 'alignment_completed'));
catch
    tf = false;
end
end

function status = get_completed_output_status(out_file, reference_file, new_input_files)
status = 'conflict';
try
    out_options = CaliAli_load(out_file, 'CaliAli_options');
catch
    status = 'legacy';
    return
end
if ~isfield(out_options, 'inter_session_alignment') || ...
        ~isfield(out_options.inter_session_alignment, 'incremental_alignment')
    status = 'legacy';
    return
end

metadata = out_options.inter_session_alignment.incremental_alignment;
if isfield(metadata, 'new_input_files')
    previous_new_files = row_cell(metadata.new_input_files);
elseif isfield(metadata, 'new_input_file')
    previous_new_files = {metadata.new_input_file};
else
    previous_new_files = {};
end

same_reference = isfield(metadata, 'reference_aligned_file') && ...
    strcmp(char(metadata.reference_aligned_file), char(reference_file));
same_new_files = isequal(previous_new_files, row_cell(new_input_files));
has_incremental_flag = isfield(out_options.inter_session_alignment, 'incremental') && ...
    isscalar(out_options.inter_session_alignment.incremental) && ...
    logical(out_options.inter_session_alignment.incremental);
has_incremental_crop = has_incremental_flag && ...
    isfield(out_options.inter_session_alignment, 'incremental_mask') && ...
    ~isempty(out_options.inter_session_alignment.incremental_mask);
if same_reference && same_new_files && has_incremental_crop
    status = 'match';
    return
end

if same_reference && same_new_files
    status = 'legacy';
end
end

function out_file = get_incremental_aligned_output_file(new_input_files)
if ischar(new_input_files) || (isstring(new_input_files) && isscalar(new_input_files))
    new_input_files = {char(new_input_files)};
end
last_input_file = new_input_files{end};
[filepath, name] = fileparts(last_input_file);
if endsWith(name, '_det')
    name = name(1:end-4);
end
out_file = fullfile(filepath, [name, '_Aligned.mat']);
end

function ranges = load_new_det_ranges(output_files)
ranges = cell(1, numel(output_files));
for i = 1:numel(output_files)
    det_opt = CaliAli_load(output_files{i}, 'CaliAli_options.inter_session_alignment');
    if isfield(det_opt, 'range')
        ranges{i} = det_opt.range;
    else
        ranges{i} = [];
    end
end
if isscalar(ranges)
    ranges = ranges{1};
end
end

function warn_incremental_option_mismatches(current_options, reference_options)
checks = {
    'inter_session_alignment.gSig'
    'inter_session_alignment.sf'
    'inter_session_alignment.BVsize'
    'inter_session_alignment.do_alignment_translation'
    'inter_session_alignment.do_alignment_non_rigid'
    'inter_session_alignment.projections'
    'inter_session_alignment.final_neurons'
    'inter_session_alignment.Force_BV'
    'preprocessing.neuron_enhance'
    'preprocessing.noise_scale'
    'preprocessing.detrend'
    'preprocessing.remove_BV'
    'preprocessing.force_non_negative'
    'preprocessing.force_non_negative_tolerance'
    'preprocessing.structure'
    'preprocessing.dendrite_filter_size'
    'preprocessing.dendrite_theta'
    'preprocessing.fastPNR'
    'preprocessing.median_filtering'
    };

mismatches = {};
for i = 1:numel(checks)
    field_path = checks{i};
    [has_current, current_value] = get_nested_field(current_options, field_path);
    [has_reference, reference_value] = get_nested_field(reference_options, field_path);
    if has_current && has_reference && ~values_equal(current_value, reference_value)
        mismatches{end+1} = field_path; %#ok<AGROW>
    end
end

if ~isempty(mismatches)
    warning('CaliAli:IncrementalAlignment:OptionMismatch', ...
        ['Incremental alignment uses the configuration saved in the reference ', ...
        'aligned file. The current options differ in: %s. The current values ', ...
        'for these fields will be ignored.'], strjoin(mismatches, ', '));
end
end

function [tf, value] = get_nested_field(S, field_path)
parts = strsplit(field_path, '.');
value = S;
tf = true;
for i = 1:numel(parts)
    if isstruct(value) && isfield(value, parts{i})
        value = value.(parts{i});
    else
        tf = false;
        value = [];
        return
    end
end
end

function tf = values_equal(a, b)
if isempty(a) && isempty(b)
    tf = true;
    return
end

try
    if isnumeric(a) || islogical(a)
        tf = (isnumeric(b) || islogical(b)) && isequaln(a, b);
    elseif ischar(a) || (isstring(a) && isscalar(a))
        tf = (ischar(b) || (isstring(b) && isscalar(b))) && strcmp(char(a), char(b));
    elseif iscell(a)
        tf = iscell(b) && isequaln(a, b);
    else
        tf = isequaln(a, b);
    end
catch
    tf = false;
end
end

function options = prepare_incremental_processing_options(original_options, new_input_files)
if ischar(new_input_files) || (isstring(new_input_files) && isscalar(new_input_files))
    new_input_files = {char(new_input_files)};
end
new_input_files = normalize_new_input_files(new_input_files);
options = original_options;
opt = options.inter_session_alignment;
opt.input_files = new_input_files;
opt.output_files = [];
opt.out_aligned_sessions = [];
opt.input_F = [];
opt.input_file_labels = {};
opt.detrend_F = [];
opt.alignment_metrics = [];
opt.T_Mask = [];
opt.NR_Mask = [];
opt.NR_Mask_n = [];
opt.F = [];
opt.T = [];
opt.Cn = [];
opt.PNR = [];
opt.P = [];
opt.shifts = [];
opt.shifts_n = [];
opt.incremental = false;
opt.incremental_mask = [];
opt.BV_score = [];
opt.range = [];
opt.Cn_scale = [];
opt.same_ses_id = [];
if isfield(opt, 'Mask')
    opt.Mask = [];
end
options.inter_session_alignment = opt;
end

function [opt, P] = calculate_incremental_alignment(original_opt, new_session_opt, ...
    P_new_original, reference_file, new_input_files, out_file)

opt = original_opt;
opt.projections = original_opt.projections;

[opt, P, P_new_translated, P_new_aligned, new_T, new_shifts, new_shifts_n, crop_info] = ...
    calculate_incremental_alignment_once(opt, P_new_original);

if contains(original_opt.projections, 'BV')
    opt.BV_score = get_BV_NR_score(P, 2);
    cprintf('-comment', 'Blood-vessel similarity score: %1.3f \n', opt.BV_score);
    if opt.BV_score < 2.7 && opt.Force_BV == 0
        cprintf('*red', 'Blood-vessel similarity score is too low! \n Results may not be accurate! \n');
        cprintf('blue', 'Aligning utilizing neurons data \n');
        opt.projections = 'Neuron';
        [opt, P, P_new_translated, P_new_aligned, new_T, new_shifts, new_shifts_n, crop_info] = ...
            calculate_incremental_alignment_once(opt, P_new_original);
    end
end

P = BV_gray2RGB(P, []);
opt = append_incremental_session_metadata(opt, new_session_opt, P, ...
    reference_file, new_input_files, out_file, P_new_translated, P_new_aligned, ...
    new_T, new_shifts, new_shifts_n, crop_info);
end

function [opt, P, P_new_translated, P_new_aligned, new_T, new_shifts, new_shifts_n, crop_info] = ...
    calculate_incremental_alignment_once(opt, P_new_original)

old_P = opt.P;
P_old_original = old_P.(1)(1, :);
n_new = size(P_new_original.(1){1, 1}, 3);

if opt.do_alignment_translation
    [P_new_translated, new_T] = sessions_translate_incremental(P_old_original, ...
        P_new_original, opt, opt.T_Mask);
else
    new_T = zeros(n_new, 2);
    P_new_translated = P_new_original;
end

if opt.do_alignment_non_rigid
    P_old_translated = old_P.(min(2, size(old_P, 2)))(1, :);
    [P_new_aligned, new_shifts, first_crop_mask] = sessions_non_rigid_incremental(P_old_translated, ...
        P_new_translated, opt, opt.NR_Mask, false);
else
    new_shifts = [];
    P_new_aligned = P_new_translated;
    first_crop_mask = true(size(P_new_aligned.(1){1, 1}, 1), size(P_new_aligned.(1){1, 1}, 2));
end

P_old_aligned = crop_projection_table(old_P.(min(3, size(old_P, 2)))(1, :), first_crop_mask);
new_shifts_n = [];
final_crop_mask = [];
effective_NR_Mask_n = [];
incremental_mask = first_crop_mask;
if opt.final_neurons
    if size(old_P, 2) < 4
        error('CaliAli:IncrementalAlignmentReference', ...
            'The reference aligned file does not contain a final neuron-alignment projection column.');
    end
    effective_NR_Mask_n = crop_stack_by_mask(opt.NR_Mask_n, first_crop_mask);
    [P_new_final, new_shifts_n, final_crop_mask] = sessions_non_rigid_incremental(P_old_aligned, ...
        P_new_aligned, opt, effective_NR_Mask_n, true);
    incremental_mask = compose_final_incremental_mask(opt.NR_Mask_n, first_crop_mask, final_crop_mask);
    P_old_final = crop_projection_table(old_P.(4)(1, :), incremental_mask);
else
    P_new_final = P_new_aligned;
end

opt.incremental = true;
opt.incremental_mask = logical(incremental_mask);
crop_info = struct( ...
    'non_rigid_crop_mask', logical(first_crop_mask), ...
    'final_neuron_crop_mask', logical(final_crop_mask), ...
    'effective_NR_Mask_n', logical(effective_NR_Mask_n), ...
    'incremental_mask', logical(incremental_mask));

P = old_P;
P.(1) = concatenate_projection_tables(old_P.(1)(1, :), P_new_original);
if size(P, 2) >= 2
    P.(2) = concatenate_projection_tables(old_P.(2)(1, :), P_new_translated);
end
if size(P, 2) >= 3
    P.(3) = concatenate_projection_tables(P_old_aligned, P_new_aligned);
end
if opt.final_neurons
    P.(4) = concatenate_projection_tables(P_old_final, P_new_final);
end
end

function out = crop_projection_table(in, mask)
out = in;
for i = 1:min(4, size(in, 2))
    out.(i){1, 1} = crop_stack_by_mask(in.(i){1, 1}, mask);
end
if size(in, 2) >= 5
    out.(5){1, 1} = [];
end
end

function mask = compose_final_incremental_mask(reference_final_mask, first_crop_mask, final_crop_mask)
idx = reshape(1:numel(reference_final_mask), size(reference_final_mask));
saved_reference_idx = crop_stack_by_mask(idx, reference_final_mask);
first_idx = crop_stack_by_mask(idx, first_crop_mask);
effective_final_mask = crop_stack_by_mask(reference_final_mask, first_crop_mask);
final_target_idx = crop_stack_by_mask(first_idx, effective_final_mask);
final_idx = crop_stack_by_mask(final_target_idx, final_crop_mask);

mask = ismember(saved_reference_idx, final_idx(:));
end

function out = concatenate_projection_tables(old_table, new_table)
out = old_table;
for i = 1:min(4, size(old_table, 2))
    old_value = old_table.(i){1, 1};
    new_value = new_table.(i){1, 1};
    validate_projection_size(old_value, new_value);
    out.(i){1, 1} = cat(3, old_value, new_value);
end
if size(old_table, 2) >= 5
    out.(5){1, 1} = [];
end
end

function validate_projection_size(old_value, new_value)
if size(old_value, 1) ~= size(new_value, 1) || size(old_value, 2) ~= size(new_value, 2)
    error('CaliAli:IncrementalAlignmentSizeMismatch', ...
        ['Incremental alignment requires the new session projections to match ', ...
        'the previous alignment reference size. Found [%d %d] and [%d %d].'], ...
        size(old_value, 1), size(old_value, 2), size(new_value, 1), size(new_value, 2));
end
end

function opt = append_incremental_session_metadata(opt, new_session_opt, P, ...
    reference_file, new_input_files, out_file, P_new_translated, P_new_aligned, ...
    new_T, new_shifts, new_shifts_n, crop_info)

new_input_files = row_cell(new_input_files);
original_F = column_or_empty(opt.F);
new_session_F = column_or_empty(new_session_opt.F);
original_input_F = column_or_empty(get_optional_field(opt, 'input_F', original_F));
new_session_input_F = column_or_empty(get_optional_field(new_session_opt, 'input_F', new_session_F));

opt.input_files = [row_cell(get_optional_field(opt, 'input_files', {})), new_input_files];
opt.output_files = [row_cell(get_optional_field(opt, 'output_files', {})), ...
    row_cell(new_session_opt.output_files)];
opt.out_aligned_sessions = out_file;
opt.F = [original_F; new_session_F];
opt.input_F = [original_input_F; new_session_input_F];
opt.detrend_F = [column_or_empty(get_optional_field(opt, 'detrend_F', original_F)); ...
    column_or_empty(get_optional_field(new_session_opt, 'detrend_F', new_session_F))];
opt.input_file_labels = [row_cell(get_optional_field(opt, 'input_file_labels', {})), new_input_files];
opt.range = [column_or_empty(get_optional_field(opt, 'range', [])); ...
    column_or_empty(get_optional_field(new_session_opt, 'range', []))];
opt.P = P;
opt.same_ses_id = [];
opt.incremental = true;
opt.incremental_mask = crop_info.incremental_mask;

if opt.do_alignment_translation
    opt.T = [opt.T; new_T];
end
if opt.do_alignment_non_rigid && ~isempty(new_shifts)
    opt.shifts = cat(4, opt.shifts, new_shifts);
end
if opt.final_neurons && ~isempty(new_shifts_n)
    if isempty(opt.shifts_n) || ...
            (size(opt.shifts_n, 1) == size(new_shifts_n, 1) && ...
            size(opt.shifts_n, 2) == size(new_shifts_n, 2) && ...
            size(opt.shifts_n, 3) == size(new_shifts_n, 3))
        opt.shifts_n = cat(4, opt.shifts_n, new_shifts_n);
    end
end

old_frame_count = sum(original_F);
new_frame_count = sum(new_session_F);
opt.incremental_alignment = struct( ...
    'reference_aligned_file', reference_file, ...
    'new_input_file', new_input_files{end}, ...
    'new_input_files', {new_input_files}, ...
    'new_det_file', new_session_opt.output_files{end}, ...
    'new_det_files', {row_cell(new_session_opt.output_files)}, ...
    'output_file', out_file, ...
    'old_frame_count', old_frame_count, ...
    'new_frame_count', new_frame_count, ...
    'total_frame_count', old_frame_count + new_frame_count, ...
    'translation_shift', new_T, ...
    'non_rigid_shift', new_shifts, ...
    'final_neuron_shift', new_shifts_n, ...
    'non_rigid_crop_mask', crop_info.non_rigid_crop_mask, ...
    'final_neuron_crop_mask', crop_info.final_neuron_crop_mask, ...
    'effective_NR_Mask_n', crop_info.effective_NR_Mask_n, ...
    'incremental_mask', crop_info.incremental_mask, ...
    'translated_projection_size', size(P_new_translated.(1){1, 1}), ...
    'aligned_projection_size', size(P_new_aligned.(1){1, 1}));
end

function value = get_optional_field(S, name, default_value)
if isfield(S, name) && ~isempty(S.(name))
    value = S.(name);
else
    value = default_value;
end
end

function out = column_or_empty(value)
if isempty(value)
    out = [];
else
    out = value(:);
end
end

function out = row_cell(value)
if isempty(value)
    out = {};
elseif iscell(value)
    out = value(:)';
else
    out = {value};
end
end

function files = normalize_new_input_files(files)
files = row_cell(files);
for i = 1:numel(files)
    files{i} = char(resolve_input_file_path(files{i}));
end
original_count = numel(files);
[files, unique_idx] = unique(files, 'stable');
if numel(unique_idx) < original_count
    warning('CaliAli:IncrementalAlignment:duplicateInput', ...
        'Duplicate incremental new-session inputs were detected and ignored.');
end
end

function path = resolve_input_file_path(entry)
if iscell(entry)
    path = entry{1};
else
    path = entry;
end
end

function stack = crop_stack_by_mask(stack, mask)
if isempty(mask)
    return
end
if size(stack, 1) ~= size(mask, 1) || size(stack, 2) ~= size(mask, 2)
    error('CaliAli:IncrementalAlignmentSizeMismatch', ...
        'Stack and incremental crop mask sizes do not match.');
end
f1 = max(sum(mask, 1));
f2 = max(sum(mask, 2));
stack = reshape(stack, size(stack, 1) * size(stack, 2), []);
stack = stack(logical(mask), :);
stack = reshape(stack, f1, f2, []);
end

function output_size = cropped_spatial_size(mask)
output_size = [max(sum(mask, 1)), max(sum(mask, 2))];
end

function CaliAli_options = apply_incremental_transformations(CaliAli_options, reference_file, new_input_batches)
flag_field = 'alignment_completed';
out_file = CaliAli_options.inter_session_alignment.out_aligned_sessions;
if is_completed_alignment_file(out_file)
    fprintf(1, 'File with name "%s" already exists.\n', out_file);
    return
elseif isfile(out_file)
    warning('CaliAli:IncrementalAlignment:incompleteFile', ...
        'Found incomplete incremental aligned file. Recomputing...');
    delete(out_file);
end

CaliAli_save(out_file, flag_field, false);

old_mat = matfile(reference_file);
out_mat = matfile(out_file, 'Writable', true);
old_info = whos(old_mat, 'Y');
if isempty(old_info) || numel(old_info.size) < 3
    error('CaliAli:IncrementalAlignmentReference', 'Reference aligned file does not contain a valid Y stack.');
end

old_size = old_info.size;
old_frames = old_size(3);
new_frames = sum(column_or_empty(CaliAli_options.inter_session_alignment.F)) - old_frames;
total_frames = old_frames + new_frames;
incremental_mask = CaliAli_options.inter_session_alignment.incremental_mask;
if isempty(incremental_mask)
    incremental_mask = true(old_size(1), old_size(2));
end
if size(incremental_mask, 1) ~= old_size(1) || size(incremental_mask, 2) ~= old_size(2)
    error('CaliAli:IncrementalAlignmentSizeMismatch', ...
        'The incremental mask size does not match the reference aligned stack size.');
end
output_size = cropped_spatial_size(incremental_mask);
out_mat.Y(output_size(1), output_size(2), total_frames) = cast(0, old_info.class);

copy_batch = max(1, min(1000, old_frames));
for start_frame = 1:copy_batch:old_frames
    end_frame = min(start_frame + copy_batch - 1, old_frames);
    out_mat.Y(:, :, start_frame:end_frame) = crop_stack_by_mask( ...
        old_mat.Y(:, :, start_frame:end_frame), incremental_mask);
end

write_start = old_frames + 1;
new_input_batches = row_cell(new_input_batches);
old_session_count = numel(CaliAli_options.inter_session_alignment.F) - numel(new_input_batches);
metadata = CaliAli_options.inter_session_alignment.incremental_alignment;
for k = 1:numel(new_input_batches)
    batch = new_input_batches{k};
    batch{1} = batch{5};
    ses_ix = old_session_count + k;
    Y = CaliAli_load(batch, 'Y');
    if CaliAli_options.inter_session_alignment.do_alignment_translation
        Y = apply_incremental_translations(Y, ...
            CaliAli_options.inter_session_alignment.T(ses_ix, :), ...
            CaliAli_options.inter_session_alignment.T_Mask);
    end
    if CaliAli_options.inter_session_alignment.do_alignment_non_rigid
        Y = apply_incremental_NR_shifts(Y, ...
            CaliAli_options.inter_session_alignment.shifts(:, :, :, ses_ix), ...
            CaliAli_options.inter_session_alignment.NR_Mask);
        Y = crop_stack_by_mask(Y, metadata.non_rigid_crop_mask);
    end
    if CaliAli_options.inter_session_alignment.final_neurons
        final_shift = get_incremental_final_neuron_shift(CaliAli_options.inter_session_alignment, k, ses_ix);
        Y = apply_incremental_NR_shifts(Y, ...
            final_shift, metadata.effective_NR_Mask_n);
        Y = crop_stack_by_mask(Y, metadata.final_neuron_crop_mask);
    end
    if size(Y, 1) ~= output_size(1) || size(Y, 2) ~= output_size(2)
        error('CaliAli:IncrementalAlignmentSizeMismatch', ...
            'Incremental transformed session size [%d %d] does not match output size [%d %d].', ...
            size(Y, 1), size(Y, 2), output_size(1), output_size(2));
    end
    write_end = write_start + size(Y, 3) - 1;
    out_mat.Y(:, :, write_start:write_end) = Y;
    write_start = write_end + 1;
end

if write_start ~= total_frames + 1
    report_frame_issue(out_file, 'incremental alignment output verification', total_frames, write_start - 1);
else
    [isZero, errMsg] = last_frame_is_zero(out_file);
    if isZero
        report_frame_issue(out_file, 'incremental alignment output last frame check', total_frames, 0, errMsg);
        error('CaliAli:frameCheck', 'Last frame of %s is all zeros.', out_file);
    end
    CaliAli_save(out_file, flag_field, true);
end
end

function shift = get_incremental_final_neuron_shift(opt, new_session_index, ses_ix)
if isfield(opt, 'incremental_alignment') && ...
        isfield(opt.incremental_alignment, 'final_neuron_shift') && ...
        ~isempty(opt.incremental_alignment.final_neuron_shift)
    shifts = opt.incremental_alignment.final_neuron_shift;
    if size(shifts, 4) >= new_session_index
        shift = shifts(:, :, :, new_session_index);
        return
    end
end
shift = opt.shifts_n(:, :, :, ses_ix);
end

function Vid = apply_incremental_translations(Vid, T, Mask)
[d1, d2] = size(Mask);
f1 = max(sum(Mask, 1));
f2 = max(sum(Mask, 2));
Vid = imtranslate(Vid, T);
Vid = reshape(Vid, d1 * d2, []);
Vid = Vid(logical(Mask), :);
Vid = reshape(Vid, f1, f2, []);
end

function Vid = apply_incremental_NR_shifts(Vid, S, Mask)
parfor i = 1:size(Vid, 3)
    Vid(:, :, i) = imwarp(Vid(:, :, i) + 1, S, 'FillValues', 1);
end
f1 = max(sum(Mask, 1));
f2 = max(sum(Mask, 2));
Vid = reshape(Vid, size(Vid, 1) * size(Vid, 2), []);
Vid(~Mask(:), :) = [];
Vid = reshape(Vid, f1, f2, []);
end

function CaliAli_options = remove_invalid_incremental_detrend_outputs(CaliAli_options)
files = normalize_new_input_files(CaliAli_options.inter_session_alignment.input_files);
CaliAli_options.inter_session_alignment.input_files = files;

for k = 1:numel(files)
    input_file = files{k};
    det_file = get_detrended_output_file(input_file);
    if strcmp(det_file, input_file) || ~isfile(det_file)
        continue
    end

    try
        dims = get_data_dimension(input_file);
        expected_frames = dims(3);
    catch
        expected_frames = NaN;
    end

    actual_frames = safe_count_frames(det_file);
    [last_frame_zero, errMsg] = last_frame_is_zero(det_file);
    bad_frame_count = ~isnan(expected_frames) && actual_frames ~= expected_frames;
    if bad_frame_count || last_frame_zero
        if bad_frame_count
            report_frame_issue(input_file, 'incremental detrended output validation', ...
                expected_frames, actual_frames);
        end
        if last_frame_zero
            report_frame_issue(input_file, 'incremental detrended output validation last frame check', ...
                actual_frames, 0, errMsg);
        end
        delete(det_file);
        fprintf(1, 'Deleted incomplete incremental detrended output "%s".\n', det_file);
    end
end
end

function det_file = get_detrended_output_file(input_file)
[filepath, name, ext] = fileparts(input_file);
if ~contains(name, '_det')
    det_file = fullfile(filepath, [name, '_det', ext]);
else
    det_file = fullfile(filepath, [name, ext]);
end
end

function CaliAli_options = record_input_frame_counts(CaliAli_options)
files = normalize_new_input_files(CaliAli_options.inter_session_alignment.input_files);
CaliAli_options.inter_session_alignment.input_files = files;
if isempty(files)
    CaliAli_options.inter_session_alignment.input_F = [];
    CaliAli_options.inter_session_alignment.input_file_labels = {};
    return
end
src_paths = cellfun(@(f) resolve_source_file(f), files, 'UniformOutput', false);
remove_corrupted_output(src_paths);

num_sessions = max(cellfun(@(idx) resolve_session_id(files{idx}, idx), num2cell(1:numel(files))));
input_F = zeros(num_sessions, 1);
labels = cell(num_sessions, 1);

for k = 1:numel(files)
    session_id = resolve_session_id(files{k}, k);
    src_file = resolve_source_file(files{k});
    try
        dims = get_data_dimension(src_file);
        input_F(session_id) = dims(3);
        if isempty(labels{session_id})
            labels{session_id} = src_file;
        end
        [isZero, errMsg] = last_frame_is_zero(src_file);
        if isZero
            report_frame_issue(labels{session_id}, 'input last frame check', dims(3), 0, errMsg);
            error('CaliAli:frameCheck', 'Last frame of %s is all zeros.', src_file);
        end
    catch ME
        report_frame_issue(src_file, 'input frame count (pre-detrend)', NaN, NaN, ME.message);
    end
end

CaliAli_options.inter_session_alignment.input_F = input_F;
CaliAli_options.inter_session_alignment.input_file_labels = labels;
end

function CaliAli_options = verify_detrended_outputs(CaliAli_options)
input_F = CaliAli_options.inter_session_alignment.input_F;
labels = ensure_labels(CaliAli_options.inter_session_alignment);
det_files = CaliAli_options.inter_session_alignment.output_files;
det_F = zeros(numel(input_F), 1);

if numel(det_files) ~= numel(input_F)
    report_frame_issue('All sessions', 'detrend_batch_and_calculate_projections (file count mismatch)', numel(input_F), numel(det_files));
end

for k = 1:min(numel(det_files), numel(input_F))
    det_file = det_files{k};
    actual_frames = safe_count_frames(det_file);
    det_F(k) = actual_frames;
    if input_F(k) ~= actual_frames
        report_frame_issue(labels{k}, 'detrend_batch_and_calculate_projections', input_F(k), actual_frames);
    end
    [isZero, errMsg] = last_frame_is_zero(det_file);
    if isZero
        report_frame_issue(labels{k}, 'detrend_batch_and_calculate_projections last frame check', actual_frames, 0, errMsg);
        error('CaliAli:frameCheck', 'Last frame of %s is all zeros.', det_file);
    end
end

CaliAli_options.inter_session_alignment.detrend_F = det_F;
end

function session_id = resolve_session_id(entry, default_id)
if iscell(entry) && numel(entry) >= 2 && isnumeric(entry{2})
    session_id = entry{2};
else
    session_id = default_id;
end
end

function src_file = resolve_source_file(entry)
if iscell(entry)
    src_file = entry{1};
else
    src_file = entry;
end
end

function labels = ensure_labels(opt)
if isfield(opt, 'input_file_labels') && ~isempty(opt.input_file_labels)
    labels = opt.input_file_labels;
else
    labels = repmat({''}, numel(opt.input_F), 1);
end
end

function n_frames = safe_count_frames(path)
try
    m = matfile(path);
    info = whos(m, 'Y');
    if isempty(info) || numel(info.size) < 3
        n_frames = 0;
    else
        n_frames = info.size(3);
    end
catch
    n_frames = 0;
end
end

function [isZero, errMsg] = last_frame_is_zero(path)
errMsg = '';
try
    m = matfile(path);
    info = whos(m, 'Y');
    if isempty(info) || numel(info.size) < 3
        isZero = true;
        errMsg = 'Y is missing or empty';
        return
    end
    lastFrameIdx = info.size(3);
    if lastFrameIdx < 1
        isZero = true;
        errMsg = 'Y has no frames';
        return
    end
    lastFrame = m.Y(:, :, lastFrameIdx);
    isZero = ~any(lastFrame(:));
    if isZero
        errMsg = 'last frame is all zeros';
    end
catch ME
    isZero = true;
    errMsg = ME.message;
end
end

function report_frame_issue(session_label, stage_label, expected, actual, errMsg)
if nargin < 5
    errMsg = '';
end
if isempty(session_label)
    session_label = 'Unknown session';
end
if exist('cprintf', 'file')
    cprintf('_red', 'Frame count mismatch for %s during %s: expected %g, found %g. %s\n', ...
        session_label, stage_label, expected, actual, errMsg);
else
    fprintf(2, 'Frame count mismatch for %s during %s: expected %g, found %g. %s\n', ...
        session_label, stage_label, expected, actual, errMsg);
end
end

function save_relevant_variables(CaliAli_options)
P = CaliAli_options.inter_session_alignment.P;
CaliAli_options.inter_session_alignment.Cn = max(P.(size(P, 2))(1, :).(3){1, 1}, [], 3);
CaliAli_options.inter_session_alignment.Cn_scale = max(CaliAli_options.inter_session_alignment.Cn, [], 'all');
CaliAli_options.inter_session_alignment.Cn = CaliAli_options.inter_session_alignment.Cn ./ ...
    CaliAli_options.inter_session_alignment.Cn_scale;
CaliAli_options.inter_session_alignment.PNR = max(P.(size(P, 2))(1, :).(4){1, 1}, [], 3);
CaliAli_save(CaliAli_options.inter_session_alignment.out_aligned_sessions(:), CaliAli_options);
end
