function C = bm_unit_batch_modes()
%% bm_unit_batch_modes: batch_sz must name what it wants instead of encoding it in a number.
%
% Zero once meant two different things depending on which module read it. The named
% modes say which, and zero still resolves to the reading its own module used.
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
try
    C{end+1} = bm_chk_true('auto is a mode', ...
        strcmp(resolve_batch_mode('auto'),'auto'), '');
    C{end+1} = bm_chk_true('all_frames is a mode', ...
        strcmp(resolve_batch_mode('all_frames'),'all_frames'), '');
    C{end+1} = bm_chk_true('per_session is a mode', ...
        strcmp(resolve_batch_mode('per_session'),'per_session'), '');
    [m,n] = resolve_batch_mode(250);
    C{end+1} = bm_chk_true('a number is a fixed batch', ...
        strcmp(m,'fixed') && n==250, sprintf('%s %d', m, n));

    C{end+1} = bm_chk_true('legacy 0 means all frames at file level', ...
        strcmp(resolve_batch_mode(0),'all_frames'), '');
    C{end+1} = bm_chk_true('legacy 0 means per session after concatenation', ...
        strcmp(resolve_batch_mode(0,'per_session'),'per_session'), '');

    C{end+1} = bm_chk_num('all_frames resolves to the no-split sentinel', ...
        compute_auto_batch_size('all_frames',[],[64 64]), 0, 0);
    C{end+1} = bm_chk_num('per_session resolves to the no-split sentinel', ...
        compute_auto_batch_size('per_session',[],[64 64]), 0, 0);
    C{end+1} = bm_chk_num('a number passes through untouched', ...
        compute_auto_batch_size(250,[],[64 64]), 250, 0);
catch ME
    C{end+1} = bm_chk_fail('batch mode vocabulary', ME.message);
end

try
    resolve_batch_mode('per-session');
    C{end+1} = bm_chk_fail('a misspelled mode is rejected', 'no error raised');
catch
    C{end+1} = bm_chk_true('a misspelled mode is rejected', true, '');
end

try
    o = CaliAli_parameters('batch_sz','per_session');
    C{end+1} = bm_chk_true('a mode reaches every module', ...
        strcmp(o.downsampling.batch_sz,'per_session') && ...
        strcmp(o.motion_correction.batch_sz,'per_session') && ...
        strcmp(o.inter_session_alignment.batch_sz,'per_session'), '');

    o = CaliAli_parameters();
    o.inter_session_alignment.batch_sz = 'per_session';
    r = CaliAli_parameters(o);
    C{end+1} = bm_chk_true('a mode set on one module stays there', ...
        strcmp(r.inter_session_alignment.batch_sz,'per_session') && ...
        ~strcmp(r.motion_correction.batch_sz,'per_session'), '');
    C{end+1} = bm_chk_true('a mode survives re-parsing', ...
        isequal(CaliAli_parameters(r), r), '');

    C{end+1} = bm_chk_true('case is normalised', ...
        strcmp(CaliAli_parameters('batch_sz','PER_SESSION').downsampling.batch_sz, ...
        'per_session'), '');
catch ME
    C{end+1} = bm_chk_fail('batch mode through CaliAli_parameters', ME.message);
end

try
    CaliAli_parameters('batch_sz','per-session');
    C{end+1} = bm_chk_fail('a misspelled mode is rejected at parse', 'no error raised');
catch
    C{end+1} = bm_chk_true('a misspelled mode is rejected at parse', true, '');
end
end
