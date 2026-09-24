function C = bm_check_no_offset(ds, mc, opt)
%% No stage may shift the whole recording by a constant.
% The pipeline used to add 1 in two places so that 0 could mean "border fill".
% Nothing subtracted it, so the data carried a permanent offset.
C = {};
if isequal(ds, mc), return; end
try
    a = bm_read_frame(ds{1}, 1);
    b = bm_read_frame(mc{1}, 1);
    m = opt.motion_correction.Mask;
    if ~isempty(m) && isequal(size(m), size(b))
        inside = logical(m);
        % compare only where both hold real data
        da = double(a(inside)); db = double(b(inside));
        shift = median(db) - median(da);
        C{end+1} = bm_chk_num('offset introduced by motion correction', shift, 0, 0.5);
    end
catch ME
    C{end+1} = bm_chk_fail('offset', ME.message);
end
end
