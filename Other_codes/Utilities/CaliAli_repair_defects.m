function CaliAli_options = CaliAli_repair_defects(files, CaliAli_options, stage)
%% CaliAli_repair_defects: Fix sensor defects in files that have not had it done.
%
% Dead pixels, dropped frames and leftover borders all have the same effect on
% this pipeline: they are structure that does NOT move with the tissue, and
% motion correction registers against whatever does not move. Three dead pixels
% were enough to collapse the estimated shifts of a session from a standard
% deviation of 2.8 pixels to 0.4 -- motion correction stopped working, and said
% nothing.
%
% WHERE IT NORMALLY RUNS. In the standard pipeline this happens inside
% CaliAli_downsample, on RAW frames, because that is the only point where a dead
% pixel is still a single pixel: spatial downsampling averages it into its
% neighbours, and temporal downsampling averages a dropped frame into the ones
% around it.
%
% THIS FUNCTION IS THE BACKUP. A recording that was motion-corrected outside
% CaliAli, or downsampled by an older version, reaches motion correction,
% alignment or detrending without ever having been through that. Each of those
% stages calls this first, so such a file is still repaired -- on downsampled
% data, which catches borders and dropped frames fully and dead pixels only
% partially. That weaker case is the price of entering late, not a reason to
% skip it.
%
% HOW IT KNOWS TO SKIP. The record is kept in the CaliAli_options saved INSIDE
% each file, not in the struct passed between stages. A struct is shared by every
% file in a call, so a flag living there would mark a second batch as done when
% only the first had been. Read from the file, the answer is about that file.
%
% Inputs:
%   files           - cell array of .mat paths (or batch cells) to check
%   CaliAli_options - the pipeline options
%   stage           - name of the calling stage, for the message
%
% Outputs:
%   CaliAli_options - unchanged except for the summary of what was repaired
%
% Author: Pablo Vergara

if nargin < 3 || isempty(stage), stage = 'this stage'; end
if ischar(files) || isstring(files), files = {char(files)}; end

if ~repair_is_enabled(CaliAli_options)
    return
end

paths = unique(cellfun(@(f) first_path(f), files, 'UniformOutput', false), 'stable');

for i = 1:numel(paths)
    f = paths{i};
    if defects_already_repaired(f)
        continue
    end
    cprintf('-comment', ...
        ['%s: %s has no record of being checked for sensor defects. ' ...
         'Checking it now.\n'], stage, f);
    repair_one_file(f, CaliAli_options);
end
end


function repair_one_file(f, CaliAli_options)
%% Scan a sample, repair every chunk, record what was done.
dims = get_data_dimension(f);
T = dims(3);

% A sample spread across the recording, not the first frames: a defect has to be
% judged against the whole session, and the start of a recording is the least
% representative part of it.
idx = unique(round(linspace(1, T, min(T, 120))));
sample = zeros(dims(1), dims(2), numel(idx), 'double');
for k = 1:numel(idx)
    sample(:,:,k) = double(CaliAli_load(f, 'Y', [idx(k), idx(k)]));
end

report = find_frame_defects(sample, repair_settings(CaliAli_options));
report.stage = 'backup';
report.spatial_ds_applied = true;   % this data is already downsampled

cropped = numel(report.rows) < dims(1) || numel(report.cols) < dims(2);
if report.n_dead == 0 && ~cropped
    record_repair(f, report);        % nothing to do, but say it was checked
    return
end

cprintf('-comment', '  %d dead pixels, border %d px\n', report.n_dead, report.border_px);

chunk = compute_auto_batch_size(batch_size_of(CaliAli_options), f);
if chunk <= 0 || chunk > T, chunk = T; end

w = whos(matfile(f), 'Y');
[pth, nam, ext] = fileparts(f);
tmp = fullfile(pth, [nam '_repair_tmp' ext]);
if isfile(tmp), delete(tmp); end

mt = matfile(tmp, 'Writable', true);
mt.Y(numel(report.rows), numel(report.cols), T) = cast(0, w.class);
for t1 = 1:chunk:T
    t2 = min(t1+chunk-1, T);
    Y = CaliAli_load(f, 'Y', [t1, t2]);
    Y = repair_frames(Y, report);
    mt.Y(:, :, t1:t2) = cast(Y, w.class);
end
clear mt

o = CaliAli_load(f, 'CaliAli_options');
CaliAli_save(tmp, 'CaliAli_options', o);
movefile(tmp, f, 'f');

record_repair(f, report);
end


function record_repair(f, report)
%% Write the record into the file's own options, so no stage repeats the work.
o = CaliAli_load(f, 'CaliAli_options');
o.defects_repaired = report;
CaliAli_save(f, 'CaliAli_options', o);
end


function tf = defects_already_repaired(f)
tf = false;
try
    r = CaliAli_load(f, 'CaliAli_options.defects_repaired');
    tf = ~isempty(r);
catch
    % no options, or no such field: it has not been done
end
end


function tf = repair_is_enabled(CaliAli_options)
tf = true;
if isstruct(CaliAli_options) && isfield(CaliAli_options, 'repair_defects') ...
        && ~isempty(CaliAli_options.repair_defects)
    tf = logical(CaliAli_options.repair_defects);
end
end


function s = repair_settings(CaliAli_options)
s = struct('dead_pixel_factor', [], 'repair_borders', []);
for fn = {'dead_pixel_factor','repair_borders'}
    if isstruct(CaliAli_options) && isfield(CaliAli_options, fn{1})
        s.(fn{1}) = CaliAli_options.(fn{1});
    end
end
end


function b = batch_size_of(CaliAli_options)
b = 'auto';
if isstruct(CaliAli_options) && isfield(CaliAli_options,'batch_sz') ...
        && ~isempty(CaliAli_options.batch_sz)
    b = CaliAli_options.batch_sz;
end
end


function p = first_path(f)
if iscell(f), f = f{1}; end
p = char(f);
end
