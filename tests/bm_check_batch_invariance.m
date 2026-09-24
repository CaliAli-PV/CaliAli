function C = bm_check_batch_invariance(scenarios)
%% bm_check_batch_invariance: Chunking must change the memory used, not the numbers.
%
% A, B and C differ only in batch size, so their downsampled output must be
% bit-identical.
%
% Inputs:
%   scenarios - The records from bm_run_scenarios.
%
% Outputs:
%   C - Cell array of check results.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

C = {};
ids = {'A','B','C'};
if isempty(scenarios)
    C{end+1} = bm_chk_fail('batch invariance', 'no scenario completed');
    return
end
have = cellfun(@(x) any(strcmp({scenarios.id},x) & [scenarios.ok]), ids);
if sum(have) < 2
    C{end+1} = bm_chk_fail('batch invariance', 'fewer than two of A, B, C completed');
    return
end
ids = ids(have);
try
    ref = [];
    for i = 1:numel(ids)
        r = scenarios(strcmp({scenarios.id}, ids{i}));
        m = matfile(r.ds_files{1});
        Y = m.Y;
        if isempty(ref)
            ref = Y; ref_id = ids{i};
        else
            C{end+1} = bm_chk_true(sprintf('batch invariance: %s matches %s', ids{i}, ref_id), ...
                isequal(Y, ref), sprintf('%s vs %s', mat2str(size(Y)), mat2str(size(ref)))); %#ok<AGROW>
        end
    end
catch ME
    C{end+1} = bm_chk_fail('batch invariance', ME.message);
end
end
