function mode = detect_incremental_alignment_mode(input_files)
%% detect_incremental_alignment_mode: Detect v1 incremental alignment inputs.

if ischar(input_files) || (isstring(input_files) && isscalar(input_files))
    input_files = {char(input_files)};
end

mode = struct('is_incremental', false, ...
    'reference_aligned_file', '', ...
    'new_input_file', '', ...
    'new_input_files', {{}});

if isempty(input_files)
    return
end

aligned_idx = false(1, numel(input_files));
for i = 1:numel(input_files)
    entry = input_files{i};
    if iscell(entry)
        entry = entry{1};
    end
    entry = char(entry);
    [~, name, ext] = fileparts(entry);
    aligned_idx(i) = strcmpi(ext, '.mat') && endsWith(name, '_Aligned');
end

if ~any(aligned_idx)
    return
end

if sum(aligned_idx) ~= 1 || numel(input_files) < 2
    error('CaliAli:IncrementalAlignmentUnsupported', ...
        ['Incremental alignment v1 expects exactly one *_Aligned.mat ', ...
        'reference file and at least one new session .mat file.']);
end

new_entries = input_files(~aligned_idx);
new_input_files = cell(1, numel(new_entries));
for i = 1:numel(new_entries)
    new_entry = new_entries{i};
    if iscell(new_entry)
        new_entry = new_entry{1};
    end
    [~, name, ext] = fileparts(char(new_entry));
    if ~strcmpi(ext, '.mat') || endsWith(name, '_Aligned')
        error('CaliAli:IncrementalAlignmentUnsupported', ...
            'Incremental alignment expects every new session input to be a non-aligned .mat file.');
    end
    new_input_files{i} = char(new_entry);
end

mode.is_incremental = true;
aligned_entries = input_files(aligned_idx);
mode.reference_aligned_file = char(resolve_source_file(aligned_entries{1}));
mode.new_input_file = new_input_files{end};
mode.new_input_files = new_input_files;
end

function src_file = resolve_source_file(entry)
if iscell(entry)
    src_file = entry{1};
else
    src_file = entry;
end
end
