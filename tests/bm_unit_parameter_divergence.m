function C = bm_unit_parameter_divergence()
%% A value set on one module must be honoured, and a flat one must propagate.
%
% These used to be in conflict. Parameters live in a flat namespace that is
% projected into one substructure per module, and the projection used to be
% collapsed on every parse, so a per-module setting was silently discarded --
% setting inter_session_alignment.batch_sz left it at 'auto' and said nothing.
% Both now work, which needs four tiers of precedence and one rule: an EMPTY
% top-level value is the seed a parameter started with, not a setting, so it
% never overrides. gSig arrives as [] and is derived by downsampling; without
% that rule the original [] would win and undo every derivation.
C = {};
try
    base = CaliAli_demo_parameters();

    o = base; o.motion_correction.batch_sz = 250;
    r = CaliAli_parameters(o);
    C{end+1} = bm_chk_num('a per-module value is honoured', ...
        r.motion_correction.batch_sz, 250, 0);
    C{end+1} = bm_chk_true('and does not leak to the other modules', ...
        ~isequal(r.inter_session_alignment.batch_sz, 250), ...
        num2str(r.inter_session_alignment.batch_sz));

    o = base; o.batch_sz = 250;
    r = CaliAli_parameters(o);
    C{end+1} = bm_chk_true('a top-level value still reaches every module', ...
        isequal(r.downsampling.batch_sz,250) && ...
        isequal(r.motion_correction.batch_sz,250) && ...
        isequal(r.inter_session_alignment.batch_sz,250), '');

    r = CaliAli_parameters(base, 'batch_sz', 700);
    C{end+1} = bm_chk_true('a name/value pair outranks a stored value', ...
        isequal(r.downsampling.batch_sz,700) && ...
        isequal(r.motion_correction.batch_sz,700), '');

    o = base; o.downsampling.batch_sz = 0; o.inter_session_alignment.batch_sz = 250;
    r = CaliAli_parameters(o);
    C{end+1} = bm_chk_true('two different per-module values both survive', ...
        isequal(r.downsampling.batch_sz,0) && ...
        isequal(r.inter_session_alignment.batch_sz,250), '');

    % the empty-seed rule: derivation must still propagate
    r = CaliAli_parameters(base);
    C{end+1} = bm_chk_true('derived values are not undone by the empty seed', ...
        ~isempty(r.cnmf.gSiz) && ~isempty(r.cnmf.ring_radius) && ...
        ~isempty(r.downsampling.BVsize), ...
        sprintf('gSiz=%s ring=%s', mat2str(r.cnmf.gSiz), mat2str(r.cnmf.ring_radius)));

    o = base; o.motion_correction.batch_sz = 250;
    a = CaliAli_parameters(o); b = CaliAli_parameters(a);
    C{end+1} = bm_chk_true('repeated parsing is stable', isequal(a,b), '');

    C{end+1} = bm_chk_true('the deliberate preprocessing override survives', ...
        isequal(a.motion_correction.preprocessing.detrend, false) && ...
        ~isequal(a.preprocessing.detrend, false), '');
catch ME
    C{end+1} = bm_chk_fail('parameter precedence', ME.message);
end
end
