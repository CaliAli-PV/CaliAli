function files = bm_copy_inputs(src, dst)
%% Each scenario gets its own copy, so nothing is shared or reused.
files = cell(size(src));
for i = 1:numel(src)
    [~,n,e] = fileparts(src{i});
    files{i} = fullfile(dst,[n e]);
    copyfile(src{i}, files{i});
end
files = files(:)';
end
