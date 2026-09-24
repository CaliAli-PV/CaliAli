function C = bm_unit_w_overlap()
%% bm_unit_w_overlap: Patch padding must follow the patch size.
%
% Inputs:
%   None.
%
% Outputs:
%   C - Cell array of check results.

C = {};
try
    d = CNMFE_parameters(struct('gSig',3));
    C{end+1} = bm_chk_num('default patch padding unchanged', d.pars_envs.w_overlap, 32, 0);
    s = CNMFE_parameters(struct('gSig',3,'pars_envs',struct('patch_dims',[32 32])));
    C{end+1} = bm_chk_num('padding follows a 32x32 patch', s.pars_envs.w_overlap, 16, 0);
    e = CNMFE_parameters(struct('gSig',3,'pars_envs',struct('patch_dims',[32 32],'w_overlap',8)));
    C{end+1} = bm_chk_num('explicit padding is still honoured', e.pars_envs.w_overlap, 8, 0);
catch ME
    C{end+1} = bm_chk_fail('w_overlap', ME.message);
end
end
