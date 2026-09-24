function C = bm_check_size_reconciliation(ds, aligned, opt)
%% Sessions of different size must be reconciled, not silently truncated.
%
% Motion correction run per session outside CaliAli crops each one differently,
% so the sessions arrive at different sizes. match_video_size crops them all to
% the region they share, and alignment then crops again to the region that is
% still valid after the sessions have been shifted onto each other.
%
% The earlier version of this check asserted that the aligned frame is at least
% as large as the smallest input. That can never hold, and the assertion was
% wrong rather than the pipeline: cropping to the valid region is what alignment
% is for. Scenario A loses 7 rows and 9 columns the same way and was only silent
% about it because it does not enable this check.
%
% What is worth asserting is that the loss is ACCOUNTED FOR: no frame is
% dropped, the result is no larger than the region the sessions share, and it is
% smaller than that region by no more than the shifts can explain.
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
