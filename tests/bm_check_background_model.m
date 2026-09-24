function C = bm_check_background_model()
%% bm_check_background_model: Only the ring background is supported.
%
% svd and nmf are inherited from CNMF-E, where they were written for two-photon
% recordings, and were never implemented for the batched extraction CaliAli runs.
% Setting one must not quietly produce a different analysis from the one asked
% for, and must not stop a run either: it warns and uses ring.
%
% Inputs:
%   None.
%
% Outputs:
%   C - Cell array of check results.

C = {};
try
    o = CaliAli_parameters();
    C{end+1} = bm_chk('the default background is ring', o.cnmf.background_model, 'ring');

    for m = {'svd','nmf','SVD','something_else'}
        lastwarn('');
        st = warning('off','CaliAli:backgroundModel:unsupported');
        ok = true; got = '';
        try
            o2 = CaliAli_parameters('background_model', m{1});
            got = o2.cnmf.background_model;
        catch
            ok = false;
        end
        [~, id] = lastwarn;
        warning(st);

        C{end+1} = bm_chk_true(sprintf('%s falls back to ring', m{1}), ...
            ok && strcmp(got,'ring'), got); %#ok<AGROW>
        C{end+1} = bm_chk_true(sprintf('%s warns while doing it', m{1}), ...
            strcmp(id,'CaliAli:backgroundModel:unsupported'), id); %#ok<AGROW>
    end
catch ME
    C{end+1} = bm_chk_fail('background model', ME.message);
end
end
