function check_version_sync()
%% check_version_sync: Check current branch and sync status
%
% Outputs:
%   status - Structure with branch and sync information
%
% Author: Pablo Vergara
% Date: 2025

% Get the directory of this script and change to it
script_path = mfilename('fullpath');
script_dir = fileparts(script_path);
original_dir = pwd;
cd(script_dir);

% Ensure we return to original directory if function exits early
cleanup = onCleanup(@() cd(original_dir));

status = struct();

% Get current branch
[~, branch_output] = system('git branch --show-current');
status.current_branch = strtrim(branch_output);

% Check for any local changes (uncommitted + staged)
[~, changes_output] = system('git status --porcelain');
status.has_changes = ~isempty(strtrim(changes_output));

% Check if current commit corresponds to a release (tag)
[~, tag_output] = system('git describe --exact-match --tags HEAD 2>/dev/null');
if ~isempty(strtrim(tag_output))
    status.release_tag = strtrim(tag_output);
    status.is_release = true;
else
    status.release_tag = '';
    status.is_release = false;
end

% Get latest release tag
[~, latest_tag_output] = system('git describe --tags --abbrev=0 2>/dev/null');
status.latest_release = strtrim(latest_tag_output);

% Check if main branch exists and get its commit
[main_status, main_commit] = system('git rev-parse main 2>/dev/null');
if main_status == 0
    status.main_commit = strtrim(main_commit);
    % Check if current HEAD is same as main
    [~, current_commit] = system('git rev-parse HEAD');
    status.is_main = strcmp(strtrim(current_commit), status.main_commit);
    
    % Check if main is same as latest release
    if ~isempty(status.latest_release)
        [~, latest_release_commit] = system(sprintf('git rev-parse %s 2>/dev/null', status.latest_release));
        status.main_is_latest_release = strcmp(status.main_commit, strtrim(latest_release_commit));
    else
        status.main_is_latest_release = false;
    end
else
    status.main_commit = '';
    status.is_main = false;
    status.main_is_latest_release = false;
end

% Output version information
fprintf('=== CaliAli Version Information ===\n');
fprintf('Branch: %s\n', status.current_branch);

if status.is_release
    fprintf('Version: %s (Official Release)\n', status.release_tag);
    % Check if there's a newer release
    if ~isempty(status.latest_release) && ~strcmp(status.release_tag, status.latest_release)
        fprintf('⚠️  Newer version available: %s\n', status.latest_release);
    end
elseif status.is_main && status.main_is_latest_release
    fprintf('Version: Main branch (same as latest release %s)\n', status.latest_release);
else
    fprintf('Version: Development/Experimental\n');
    if status.is_main
        fprintf('⚠️  You are on main branch - this is experimental/beta code\n');
    else
        fprintf('⚠️  You are on branch "%s" - this is experimental/beta code\n', status.current_branch);
    end
    if ~isempty(status.latest_release)
        fprintf('   Latest stable release: %s\n', status.latest_release);
    end
end

if status.has_changes
    fprintf('Status: ✗ Has local changes\n');
    status.is_synced = false;
else
    fprintf('Status: ✓ Clean (no local changes)\n');
    status.is_synced = true;
end

end