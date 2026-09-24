function C = bm_check_mask(opt)
%% The valid region must be a real rectangle that excludes something.
C = {};
m = [];
try m = opt.motion_correction.Mask; catch; end
if isempty(m)
    C{end+1} = bm_chk_fail('mask exists', 'motion_correction.Mask is empty');
    return
end
m = logical(m);
frac = nnz(m)/numel(m);
C{end+1} = bm_chk_true('mask covers most of the frame', frac > 0.5, sprintf('%.3f', frac));
C{end+1} = bm_chk_true('mask excludes the translated border', frac < 1, sprintf('%.3f', frac));
% a rectangle: its bounding box has the same count as the mask itself
[r,c] = find(m);
box = (max(r)-min(r)+1)*(max(c)-min(c)+1);
C{end+1} = bm_chk_true('mask is a rectangle', box == nnz(m), sprintf('%d vs %d', box, nnz(m)));
end
