function C = bm_unit_translation_bound()
%% The border ignored while estimating the session shift must scale.
%
% It was a flat 20 pixels whatever the recording, which is 11% of a 180-row
% frame and 26% of the same frame after spatial_ds=2 -- the smaller the frame,
% the larger the share thrown away. The replacement is a share of the frame
% capped at the old value, so it never trims MORE than before and only relaxes
% the axes that were being over-trimmed.
C = {};
try
    [b1,b2] = translation_bound_default([512 512]);
    C{end+1} = bm_chk_true('a large frame keeps the historical trim', ...
        b1==20 && b2==20, sprintf('%d / %d', b1, b2));

    [b1,b2] = translation_bound_default([78 118]);
    C{end+1} = bm_chk_true('a small frame is trimmed less', ...
        b1 < 20 && b2 <= 20, sprintf('%d / %d', b1, b2));

    over = false; grew = false;
    for d = [8 16 32 64 90 128 180 256 512 1024]
        [a,~] = translation_bound_default([d d]);
        if a > 20, over = true; end            % never more than before
        if a > 0.42*d, grew = true; end        % never most of the axis
        if mod(a,2) ~= 0, grew = true; end     % must split evenly per side
    end
    C{end+1} = bm_chk_true('never trims more than the flat 20 px it replaces', ~over, '');
    C{end+1} = bm_chk_true('never eats the frame, always even', ~grew, '');

    [a,~] = translation_bound_default([100 100]);
    [b,~] = translation_bound_default([200 200]);
    C{end+1} = bm_chk_true('monotone in frame size', a <= b, sprintf('%d <= %d', a, b));
catch ME
    C{end+1} = bm_chk_fail('translation bound', ME.message);
end
end
