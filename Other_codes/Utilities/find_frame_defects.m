function report = find_frame_defects(sample, opt)
%% find_frame_defects: Locate sensor defects, from a sample of RAW frames.
%
% Three things have to be decided ONCE for a whole recording, never per batch:
%
%   dead pixels   need temporal variance, so they cannot be judged from a few
%                 frames of one chunk. Repairing a different set of pixels in
%                 each chunk would put a seam in the recording.
%   the border    changes the frame size, and the output file is preallocated
%                 before the first chunk is written.
%   the threshold that separates a dead pixel from quiet tissue.
%
% So this runs before the chunk loop, on a sample spread across the recording,
% and returns masks that every chunk then uses unchanged.
%
% WHY THIS MUST SEE RAW FRAMES. Spatial downsampling averages a dead pixel with
% its neighbours: at spatial_ds = 2 a dead pixel leaves four output pixels at
% about three quarters of their true value, which is neither zero nor obviously
% low-variance, and the damage is already spread. The same goes for a dropped
% frame under temporal downsampling. Detection is only reliable before either.
%
% DEAD PIXEL, AND WHY NOT A GLOBAL THRESHOLD. Quiet tissue genuinely has low
% variance and is not a defect, so "below some level" would condemn real data and
% would have to be retuned for every recording. What distinguishes a defect is
% that it is ISOLATED: a dead pixel sits among live neighbours. The test is
% therefore local -- variance far below the pixels immediately around it -- which
% is one rule that holds across recordings rather than a value to tune per file.
%
% Inputs:
%   sample - [d1 d2 n] raw frames, spread across the recording
%   opt    - options with:
%              dead_pixel_factor  variance below this fraction of the local
%                                 neighbourhood median counts as dead (0.1)
%              repair_borders     crop edge-connected constant regions (true)
%
% Outputs:
%   report - struct with
%              dead         [d1 d2] logical, pixels to interpolate over
%              rows, cols   the rectangle to keep
%              n_dead       how many pixels
%              border_px    how deep the border reached, 0 if none
%              frames_used  how many frames the sample held
%
% Author: Pablo Vergara

if nargin < 2, opt = struct(); end
if ~isfield(opt,'dead_pixel_factor') || isempty(opt.dead_pixel_factor)
    opt.dead_pixel_factor = 0.1;
end
if ~isfield(opt,'repair_borders') || isempty(opt.repair_borders)
    opt.repair_borders = true;
end

sample = double(sample);
[d1, d2, n] = size(sample);

report = struct('dead', false(d1,d2), 'rows', 1:d1, 'cols', 1:d2, ...
    'n_dead', 0, 'border_px', 0, 'frames_used', n);

%% ---- the border: a constant region reaching the frame edge ---------------
% Constant, not zero. An external tool may fill with any value, and after this
% pipeline stopped adding 1 to everything, zero is a value real data can hold.
% What a fill always is, and tissue never is, is unchanging in time AND
% connected to the edge.
if opt.repair_borders && n > 1
    frozen = (max(sample, [], 3) - min(sample, [], 3)) == 0;
    border = edge_connected(frozen);
    if any(border(:))
        [~, rows, cols] = largest_valid_rectangle(~border);
        if numel(rows) < d1 || numel(cols) < d2
            report.rows = rows;
            report.cols = cols;
            report.border_px = max([rows(1)-1, d1-rows(end), cols(1)-1, d2-cols(end)]);
            % Everything after this is judged on what survives the crop, so the
            % dead-pixel mask is sized to the cropped frame -- which is the size
            % repair_frames will be holding when it applies it.
            sample = sample(rows, cols, :);
            [d1, d2, ~] = size(sample);
            report.dead = false(d1, d2);
        end
    end
end

%% ---- dead pixels: isolated low variance ---------------------------------
if n < 3
    return   % not enough frames to say anything about variance
end

v = var(sample, 0, 3);

% The neighbourhood a pixel is compared against. 5x5 is wide enough that a
% single defect cannot set its own reference, and narrow enough to follow real
% changes in brightness across the field of view.
local = medfilt2(v, [5 5], 'symmetric');

% A pixel with no variance at all is dead whatever its neighbours do.
report.dead = (v == 0) | (v < opt.dead_pixel_factor * local & local > 0);

% Only ISOLATED pixels. A whole quiet region is tissue, not a defect, and
% interpolating over it would invent data. Anything in a run wider than a couple
% of pixels is left alone.
report.dead = report.dead & ~imopen(report.dead, strel('square', 3));

report.n_dead = nnz(report.dead);
end


function B = edge_connected(S)
%% The part of S that reaches the frame edge.
B = false(size(S));
if ~any(S(:)), return; end
seed = false(size(S));
seed([1 end], :) = S([1 end], :);
seed(:, [1 end]) = S(:, [1 end]);
if ~any(seed(:)), return; end
B = imreconstruct(seed, S);
end
