function paths_added = add_paths()
%ADD_CALI_ALI_PATHS Add CaliAli functions to the MATLAB path, skipping .git.
%
% Outputs:
%   paths_added - Cell array of directories that were added to the path
%
% The function walks the CaliAli repository (relative to this file) and adds
% all subfolders to the MATLAB search path, while ignoring any `.git`
% directories to keep version-control metadata out of the path.

% Locate repository root based on this file's location
repo_root = fileparts(mfilename('fullpath'));

% Build recursive list of subfolders
raw_paths = strsplit(genpath(repo_root), pathsep);
raw_paths = raw_paths(~cellfun(@isempty, raw_paths));

% Filter out any .git directories (including nested .git folders)
is_git_path = contains(raw_paths, [filesep '.git']);
paths_added = unique(raw_paths(~is_git_path), 'stable');

% Add to MATLAB path
addpath(paths_added{:});

% Provide simple feedback when no output is requested
if nargout == 0
    fprintf('Added %d folders to the MATLAB path (excluding .git)\n', numel(paths_added));
end
end
