function C = bm_check_dropped(scn_dir, blanked_idx)
%% bm_check_dropped: A frame the camera never delivered must be found and interpolated.
%
% Inputs:
%   scn_dir, blanked_idx - The scenario folder and which frame was blanked.
%
% Outputs:
%   C - Cell array of check results.

C = {};
f = dir(fullfile(scn_dir,'*_mc.mat'));
if isempty(f)
    C{end+1} = bm_chk_fail('dropped frame', 'no _mc.mat produced');
    return
end
try
    m = matfile(fullfile(f(1).folder,f(1).name));
    w = whos(m,'Y');
    if blanked_idx > w.size(3)
        C{end+1} = bm_chk_fail('dropped frame', 'blanked frame is outside the output');
        return
    end
    fr = double(m.Y(:,:,blanked_idx));
    neighbours = double(m.Y(:,:,max(1,blanked_idx-1)));
    sd = std(fr(:));
    C{end+1} = bm_chk_true('dropped frame was interpolated, not left flat', sd > 0, ...
        sprintf('std %.3f (0 means untouched)', sd));
    C{end+1} = bm_chk_true('interpolated frame resembles its neighbour', ...
        sd == 0 || corr(fr(:), neighbours(:)) > 0.5, ...
        sprintf('corr %.3f', corr(fr(:), neighbours(:))));
catch ME
    C{end+1} = bm_chk_fail('dropped frame', ME.message);
end
end
