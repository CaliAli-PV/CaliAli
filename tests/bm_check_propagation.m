function C = bm_check_propagation(opt, ds, aligned, sim)
%% bm_check_propagation: A setting must reach the stage that uses it and be recorded in what it writes.
%
% A parameter that is quietly ignored cannot be told apart from one never set.
%
% Inputs:
%   opt, ds, aligned, sim - Options, the files written, and the ground truth.
%
% Outputs:
%   C - Cell array of check results.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

C = {};
try
    % spatial downsampling actually applied
    src = VideoReader(sim.files{1}); %#ok<TNMLP>
    want = [floor(src.Height/opt.downsampling.spatial_ds), ...
            floor(src.Width /opt.downsampling.spatial_ds)];
    got = get_data_dimension(ds{1});
    C{end+1} = bm_chk_true('spatial_ds was applied', ...
        abs(got(1)-want(1)) <= 1 && abs(got(2)-want(2)) <= 1, ...
        sprintf('%dx%d, expected about %dx%d', got(1), got(2), want(1), want(2)));

    % output_class actually applied
    C{end+1} = bm_chk('output_class was applied', bm_mat_class(ds{1}), ...
        lower(char(opt.downsampling.output_class)));

    % the settings are recorded in what the stage wrote, not just held in memory
    stored = CaliAli_load(ds{1}, 'CaliAli_options');
    C{end+1} = bm_chk_num('spatial_ds recorded in the _ds file', ...
        stored.downsampling.spatial_ds, opt.downsampling.spatial_ds, 0);
    stored_al = CaliAli_load(aligned, 'CaliAli_options');
    C{end+1} = bm_chk_num('spatial_ds survives to the aligned file', ...
        stored_al.downsampling.spatial_ds, opt.downsampling.spatial_ds, 0);

    % a setting the user never touched must not have been invented
    C{end+1} = bm_chk_num('temporal_ds left at its default', ...
        stored.downsampling.temporal_ds, 1, 0);
catch ME
    C{end+1} = bm_chk_fail('settings propagation', ME.message);
end
end
