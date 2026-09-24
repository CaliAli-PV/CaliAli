function C = bm_check_no_offset(ds, mc, opt)
%% bm_check_no_offset: No stage may shift the whole recording by a constant.
%
% Inputs:
%   ds, mc, opt - The files before and after motion correction.
%
% Outputs:
%   C - Cell array of check results.

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
