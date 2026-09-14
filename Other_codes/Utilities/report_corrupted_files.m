function bad = report_corrupted_files(thefiles, expected_frames)
%% report_corrupted_files: Name incomplete files without touching them.
%
% For files nothing will regenerate -- alignment inputs, a user's recordings.
% Deleting those does not fix anything, it loses data: no stage runs again to
% replace them. So this reports and returns, and the caller decides.
%
% Inputs:
%   thefiles        - char/string path, or cell array of paths
%   expected_frames - optional, passed to check_mat_video
%
% Output:
%   bad - cell array of paths that did not pass, {} when all did
%
% Author: Pablo Vergara

if nargin < 2, expected_frames = []; end
bad = {};
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
    if ~strcmp(status, 'corrupt'), continue; end

    bad{end+1} = f; %#ok<AGROW>
    msg = sprintf(['Input file %s looks incomplete (%s). It was NOT deleted, ' ...
        'because nothing regenerates an input. Rebuild it from its source ' ...
        'before continuing.\n'], f, reason);
    if exist('cprintf', 'file')
        cprintf('_red', '%s', msg);
    else
        fprintf(2, '%s', msg);
    end
end
end
