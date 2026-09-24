function files = bm_copy_inputs(src, dst)
%% bm_copy_inputs: Give a scenario its own copy of the input videos.
%
% Inputs:
%   src, dst - Source files and destination folder.
%
% Outputs:
%   files - The copies.

files = cell(size(src));
for i = 1:numel(src)
    [~,n,e] = fileparts(src{i});
    files{i} = fullfile(dst,[n e]);
    copyfile(src{i}, files{i});
end
files = files(:)';
end
