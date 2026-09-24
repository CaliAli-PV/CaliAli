function C = bm_check_size_reconciliation(ds, aligned, opt)
%% bm_check_size_reconciliation: Sessions of different size must be reconciled, not silently truncated.
%
% Cropping to the region every session shares is what alignment is for, so the
% question is not whether the frame shrank but whether the loss is accounted for:
% no frame dropped, nothing larger than the shared region, and nothing smaller
% than the measured shifts can explain.
%
% Inputs:
%   ds, aligned, opt - The inputs, the result and the options.
%
% Outputs:
%   C - Cell array of check results.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

C = {};
try
    sizes = zeros(numel(ds),3);
    for i = 1:numel(ds)
        sizes(i,:) = get_data_dimension(ds{i});
    end
    C{end+1} = bm_chk_true('sessions really do differ in size', ...
        numel(unique(sizes(:,1))) > 1 || numel(unique(sizes(:,2))) > 1, ...
        mat2str(sizes(:,1:2)));

    d = get_data_dimension(aligned);
    C{end+1} = bm_chk_num('no frame lost reconciling the sizes', ...
        d(3), sum(sizes(:,3)), 0);

    % The shared region: every session centred on the others, so each axis is
    % the smallest of the inputs.
    shared = [min(sizes(:,1)), min(sizes(:,2))];
    C{end+1} = bm_chk_true('aligned frame does not exceed the shared region', ...
        d(1) <= shared(1) && d(2) <= shared(2), ...
        sprintf('%dx%d vs shared %dx%d', d(1), d(2), shared(1), shared(2)));

    % What the alignment itself may cost. Each of the two registration passes,
    % translation and non-rigid, can take a row and a column off each side, and
    % a shift of s pixels costs ceil(s) more. Anything beyond that is a border
    % being thrown away for no stated reason, which is the thing worth catching.
    T = bm_getfield_or(opt.inter_session_alignment, 'T', zeros(1,2));
    if isempty(T), T = zeros(1,2); end
    budget = 2*(2 + ceil(max(abs(T(:)))));
    lost = shared - d(1:2);
    C{end+1} = bm_chk_true('border loss is no more than the shifts explain', ...
        all(lost <= budget) && all(lost >= 0), ...
        sprintf('lost %dx%d, budget %d (max |shift| %.2f)', ...
        lost(1), lost(2), budget, max(abs(T(:)))));
catch ME
    C{end+1} = bm_chk_fail('size reconciliation', ME.message);
end
end
