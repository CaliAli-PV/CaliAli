function C = bm_check_patch(opt)
%% w_overlap follows patch_dims instead of being a fixed 32.
C = {};
try
    pe = opt.cnmf.pars_envs;
    C{end+1} = bm_chk_num('w_overlap derived from patch_dims', ...
        pe.w_overlap, round(0.5*min(pe.patch_dims)), 0);
catch ME
    C{end+1} = bm_chk_fail('w_overlap', ME.message);
end
end
