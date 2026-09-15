function [flagged, report] = report_uncropped_borders(files, varname)
%% report_uncropped_borders: Warn about black borders left by an external tool.
%
% CaliAli's own motion correction records which pixels are real and crops to
% them, so a session it corrected never reaches alignment with a filled border.
% A session corrected by CaImAn, Suite2p or anything else arrives with no such
% record, and whatever the shifts left at the edges is still there. Those borders
% pull the inter-session registration towards the frame edge, which is what the
% FAQ warns about.
%
% WHY THIS ONLY WARNS. CaliAli used to crop those files itself, by treating any
% pixel equal to 0 as filled. That inference was sound only while the pipeline
% added 1 to every recording so that 0 could not occur naturally. It no longer
% does, so a genuinely dark pixel is now indistinguishable from a filled one, and
% the crop silently removed real data. There are no recorded shifts for an
% external file, so nothing can be propagated and nothing can be known for sure.
% Guessing and telling the user is honest; guessing and cropping is not.
%
% WHAT COUNTS AS EVIDENCE. A translation fill is a run of zeros CONNECTED TO THE
% FRAME EDGE, because that is where the data slid away from. A dark pixel in the
% middle of the field of view is not. Only edge-connected zeros are reported, so
% a recording that simply contains zeros is not flagged.
%
% Inputs:
%   files   - cell array of .mat paths, or a single path
%   varname - variable holding the video. Defaults to 'Y'.
%
% Outputs:
%   flagged - logical, one per file, true where a border was found
%   report  - struct array with the per-file detail (width, fraction, frames read)
%
% Author: Pablo Vergara

if nargin < 2 || isempty(varname), varname = 'Y'; end
if ischar(files) || isstring(files), files = {char(files)}; end

MAX_FRAMES = 60;      % enough to catch the extremes of a drift without reading all
MIN_FRACTION = 0.001; % a handful of pixels is noise, not a border

flagged = false(1, numel(files));
report = struct('file', {}, 'border_px', {}, 'fraction', {}, 'frames_read', {});

for i = 1:numel(files)
    f = files{i};
    if iscell(f), f = f{1}; end
    try
        dims = get_data_dimension(f);
    catch
        continue
    end
    T = dims(3);
    idx = unique(round(linspace(1, T, min(T, MAX_FRAMES))));

    % A pixel is suspicious if it is zero in ANY of the frames read.
    suspicious = false(dims(1), dims(2));
    for t = idx
        Y = CaliAli_load(f, varname, [t, t]);
        suspicious = suspicious | (Y == 0);
    end

    border = edge_connected(suspicious);
    frac = nnz(border) / numel(border);
    if frac <= MIN_FRACTION
        continue
    end

    flagged(i) = true;
    w = border_width(border);
    report(end+1) = struct('file', f, 'border_px', w, ...
        'fraction', frac, 'frames_read', numel(idx)); %#ok<AGROW>

    cprintf('*red', 'Uncropped border in %s\n', f);
    cprintf('red', ['  %.1f%% of the frame is zero at the edges, up to %d pixels deep. ' ...
        'CaliAli does not remove these, because with no record of the shifts it ' ...
        'cannot tell a filled pixel from a dark one. Crop the borders before ' ...
        'aligning, or let CaliAli do the motion correction.\n'], 100*frac, w);
end
end


function B = edge_connected(S)
%% Keep only the suspicious pixels that reach the frame edge.
B = false(size(S));
if ~any(S(:)), return; end
seed = false(size(S));
seed([1 end], :) = S([1 end], :);
seed(:, [1 end]) = S(:, [1 end]);
if ~any(seed(:)), return; end
B = imreconstruct(seed, S);
end


function w = border_width(B)
%% How deep the border reaches, as the largest inward run from any edge.
w = 0;
if ~any(B(:)), return; end
w = max([run_from(B, 1), run_from(B', 1), ...
         run_from(flipud(B), 1), run_from(flipud(B'), 1)]);
end


function n = run_from(B, ~)
%% Rows fully covered from the top, which is the depth of a straight border.
covered = all(B, 2);
n = find(~covered, 1) - 1;
if isempty(n), n = size(B, 1); end
if isempty(n), n = 0; end
end
