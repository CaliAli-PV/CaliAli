function removed = remove_corrupted_output(thefiles)
% remove_corrupted_output: delete .mat output files that are corrupted
% (smaller than 1 MB or whose last frame in Y is all zeros) so that
% downstream code can regenerate them.
%
% Inputs:
%   thefiles - char/string path or cell array of paths to candidate .mat files.
%
% Outputs:
%   removed  - cell array of paths that were deleted.

if isempty(thefiles)
    removed = {};
    return
end
if ischar(thefiles) || isstring(thefiles)
    thefiles = {char(thefiles)};
end

min_bytes = 1024 * 1024;  % 1 MB
removed = {};

for k = 1:numel(thefiles)
    output_file = thefiles{k};
    if iscell(output_file)
        output_file = output_file{1};
    end
    output_file = char(output_file);

    if ~isfile(output_file)
        continue
    end

    delete_reason = '';

    info_file = dir(output_file);
    if ~isempty(info_file) && info_file.bytes < min_bytes
        delete_reason = sprintf('file size %d bytes < 1 MB', info_file.bytes);
    else
        try
            m = matfile(output_file);
            info = whos(m, 'Y');
            if isempty(info) || numel(info.size) < 3 || info.size(3) < 1
                delete_reason = 'Y missing or has no frames';
            else
                last_idx = info.size(3);
                slice = m.Y(:,:,last_idx);
                if ~any(slice(:))
                    delete_reason = 'last frame is all zeros';
                end
            end
        catch ME
            delete_reason = sprintf('failed to read: %s', ME.message);
        end
    end

    if ~isempty(delete_reason)
        try
            delete(output_file);
            removed{end+1} = output_file; %#ok<AGROW>
            if exist('cprintf', 'file')
                cprintf('_red', 'Deleted corrupted file %s (%s)\n', output_file, delete_reason);
            else
                fprintf(2, 'Deleted corrupted file %s (%s)\n', output_file, delete_reason);
            end
        catch ME
            fprintf(2, 'Could not delete %s: %s\n', output_file, ME.message);
        end
    end
end
end
