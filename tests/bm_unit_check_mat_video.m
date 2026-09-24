function C = bm_unit_check_mat_video()
%% bm_unit_check_mat_video: The file-integrity test decides whether a file is DELETED.
%
% A false positive loses data, so the rule must be about content and not size.
%
% Inputs:
%   None.
%
% Outputs:
%   C - Cell array of check results.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

C = {};
d = tempname; mkdir(d);
try
    Y = uint16(rand(8,8,20)*1000+1); save(fullfile(d,'good.mat'),'Y','-v7.3');
    Y = uint16(rand(8,8)*1000+1);    save(fullfile(d,'flat.mat'),'Y','-v7.3');
    Y = uint16(rand(8,8,20)*1000+1); Y(:,:,end)=0; save(fullfile(d,'cut.mat'),'Y','-v7.3');
    Y = uint16(rand(1,1,3)*1000+1);  save(fullfile(d,'tiny.mat'),'Y','-v7.3');   %#ok<NASGU>

    C{end+1} = bm_chk('check_mat_video: complete file', check_mat_video(fullfile(d,'good.mat')), 'ok');
    C{end+1} = bm_chk('check_mat_video: Y not 3-D',     check_mat_video(fullfile(d,'flat.mat')), 'corrupt');
    C{end+1} = bm_chk('check_mat_video: truncated',     check_mat_video(fullfile(d,'cut.mat')),  'corrupt');
    C{end+1} = bm_chk('check_mat_video: small but valid', check_mat_video(fullfile(d,'tiny.mat')), 'ok');
    C{end+1} = bm_chk('check_mat_video: missing',       check_mat_video(fullfile(d,'nope.mat')), 'missing');
    C{end+1} = bm_chk('check_mat_video: wrong frame count', ...
        check_mat_video(fullfile(d,'good.mat'), 999), 'corrupt');

    % deleting must be confined to what is genuinely broken
    remove_corrupted_output({fullfile(d,'tiny.mat'), fullfile(d,'cut.mat')});
    C{end+1} = bm_chk_true('remove_corrupted_output keeps the valid small file', ...
        isfile(fullfile(d,'tiny.mat')), '');
    C{end+1} = bm_chk_true('remove_corrupted_output deletes the truncated file', ...
        ~isfile(fullfile(d,'cut.mat')), '');

    % reporting must never delete
    Y = uint16(rand(8,8,20)*1000+1); Y(:,:,end)=0; save(fullfile(d,'cut2.mat'),'Y','-v7.3'); %#ok<NASGU>
    bad = report_corrupted_files({fullfile(d,'cut2.mat')});
    C{end+1} = bm_chk_true('report_corrupted_files deletes nothing', ...
        isfile(fullfile(d,'cut2.mat')) && numel(bad)==1, '');
catch ME
    C{end+1} = bm_chk_fail('check_mat_video unit', ME.message);
end
rmdir(d,'s');
end
