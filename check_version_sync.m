function status = check_version_sync(files_to_check)
%% check_version_sync: Compare local files with GitHub repository version
%
% This function checks if local files match the GitHub repository version
% by comparing git status and optionally specific file contents.
%
% Inputs:
%   files_to_check - (Optional) Cell array of specific files to check
%                   If not provided, checks overall git status
%
% Outputs:
%   status - Structure with sync information
%
% Usage:
%   status = check_version_sync(); % Check overall status
%   status = check_version_sync({'Align_sessions/detrend_batch_and_calculate_projections.m'});
%
% Author: Pablo Vergara
% Date: 2025

if nargin < 1
    files_to_check = {};
end

status = struct();

fprintf('=== Checking Version Sync with GitHub ===\n\n');

%% Check if we're in a git repository
try
    [git_status, git_output] = system('git rev-parse --is-inside-work-tree');
    if git_status ~= 0
        error('Not in a git repository');
    end
catch
    status.is_git_repo = false;
    status.error = 'Not in a git repository or git not available';
    fprintf('ERROR: %s\n', status.error);
    return;
end

status.is_git_repo = true;

%% Check current branch and remote tracking
[~, branch_info] = system('git branch -vv');
fprintf('Current branch info:\n%s\n', branch_info);

%% Check if local is ahead/behind remote
fprintf('Checking remote sync status...\n');
system('git fetch'); % Update remote references

[~, status_output] = system('git status -uno'); % -uno = don't show untracked files
fprintf('Git status:\n%s\n', status_output);

%% Check for uncommitted changes
[~, diff_output] = system('git diff --name-only');
if ~isempty(strtrim(diff_output))
    status.has_uncommitted_changes = true;
    status.uncommitted_files = strsplit(strtrim(diff_output), newline);
    fprintf('Uncommitted changes found in:\n');
    for i = 1:length(status.uncommitted_files)
        fprintf('  - %s\n', status.uncommitted_files{i});
    end
else
    status.has_uncommitted_changes = false;
    fprintf('No uncommitted changes found.\n');
end

%% Check for staged changes
[~, staged_output] = system('git diff --cached --name-only');
if ~isempty(strtrim(staged_output))
    status.has_staged_changes = true;
    status.staged_files = strsplit(strtrim(staged_output), newline);
    fprintf('Staged changes found in:\n');
    for i = 1:length(status.staged_files)
        fprintf('  - %s\n', status.staged_files{i});
    end
else
    status.has_staged_changes = false;
    fprintf('No staged changes found.\n');
end

%% Check specific files if requested
if ~isempty(files_to_check)
    fprintf('\n=== Checking Specific Files ===\n');
    status.file_checks = struct();
    
    for i = 1:length(files_to_check)
        filename = files_to_check{i};
        fprintf('Checking %s...\n', filename);
        
        % Check if file has local changes
        [diff_status, diff_content] = system(sprintf('git diff HEAD -- "%s"', filename));
        
        if diff_status == 0 && isempty(strtrim(diff_content))
            status.file_checks.(matlab.lang.makeValidName(filename)).is_synced = true;
            status.file_checks.(matlab.lang.makeValidName(filename)).status = 'Synced with HEAD';
            fprintf('  ✓ %s is synced\n', filename);
        else
            status.file_checks.(matlab.lang.makeValidName(filename)).is_synced = false;
            status.file_checks.(matlab.lang.makeValidName(filename)).status = 'Has local changes';
            status.file_checks.(matlab.lang.makeValidName(filename)).diff = diff_content;
            fprintf('  ✗ %s has local changes\n', filename);
        end
    end
end

%% Check if local branch is up to date with remote
[~, rev_list_output] = system('git rev-list HEAD...@{u} --count 2>/dev/null');
if ~isempty(strtrim(rev_list_output))
    commits_diff = str2double(strtrim(rev_list_output));
    if commits_diff == 0
        status.is_up_to_date = true;
        fprintf('\n✓ Local branch is up to date with remote.\n');
    else
        status.is_up_to_date = false;
        fprintf('\n✗ Local branch differs from remote by %d commits.\n', commits_diff);
    end
else
    status.is_up_to_date = [];
    fprintf('\nWarning: Could not determine remote sync status.\n');
end

%% Summary
fprintf('\n=== SUMMARY ===\n');
if status.is_git_repo
    fprintf('Git Repository: ✓\n');
else
    fprintf('Git Repository: ✗\n');
end
if status.has_uncommitted_changes
    fprintf('Uncommitted Changes: ✗ Yes\n');
else
    fprintf('Uncommitted Changes: ✓ None\n');
end
if status.has_staged_changes
    fprintf('Staged Changes: ✗ Yes\n');
else
    fprintf('Staged Changes: ✓ None\n');
end

if ~isempty(status.is_up_to_date)
    if status.is_up_to_date
        fprintf('Remote Sync: ✓ Up to date\n');
    else
        fprintf('Remote Sync: ✗ Out of sync\n');
    end
end

if status.has_uncommitted_changes || status.has_staged_changes || (~isempty(status.is_up_to_date) && ~status.is_up_to_date)
    fprintf('\n⚠️  Your local code differs from the GitHub version!\n');
    status.needs_sync = true;
else
    fprintf('\n✅ Your local code matches the GitHub version!\n');
    status.needs_sync = false;
end

end