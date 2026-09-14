function removed = remove_corrupted_output(thefiles, expected_frames)
%% remove_corrupted_output: Delete incomplete OUTPUT files so they are regenerated.
%
% For files this pipeline produces and can rebuild. Deleting is the point: the
% stage that wrote the file runs again and writes it properly. Do NOT point this
% at anything nothing will regenerate -- an alignment input, a user's recording.
% For those, report instead: see report_corrupted_files.
%
% The verdict comes from check_mat_video, which judges whether Y is present,
% three-dimensional and ends in a written frame. There is no file-size rule. One
% existed and was wrong in both directions: it deleted a small recording that was
% fine, and kept a large one that had been cut off half way.
%
% Inputs:
%   thefiles        - char/string path, or cell array of paths
%   expected_frames - optional, passed to check_mat_video. Scalar applied to
%                     every file, or one value per file.
%
% Output:
%   removed - cell array of the paths that were deleted
%
% Author: Pablo Vergara

if nargin < 2, expected_frames = []; end
removed = {};
if isempty(thefiles), return; end
if ischar(thefiles) || isstring(thefiles), thefiles = {char(thefiles)}; end

for k = 1:numel(thefiles)
    f = thefiles{k};
    if iscell(f), f = f{1}; end
    f = char(f);

    ef = [];
    if ~isempty(expected_frames)
        if isscalar(expected_frames), ef = expected_frames;
        elseif numel(expected_frames) >= k, ef = expected_frames(k);
        end
    end

    [status, reason] = check_mat_video(f, ef);
    if ~strcmp(status, 'corrupt')
        continue   % 'missing' is not a failure: the stage simply has not run
    end

    try
        delete(f);
        removed{end+1} = f; %#ok<AGROW>
        say('_red', 'Deleted incomplete file %s (%s). It will be regenerated.\n', f, reason);
    catch ME
        fprintf(2, 'Could not delete %s: %s\n', f, ME.message);
    end
end
end

function say(style, fmt, varargin)
if exist('cprintf', 'file')
    cprintf(style, fmt, varargin{:});
else
    fprintf(2, fmt, varargin{:});
end
end
