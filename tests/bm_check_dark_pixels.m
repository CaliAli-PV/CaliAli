function C = bm_check_dark_pixels(ds, ~, dark)
%% A dead sensor pixel must be found and repaired, and must cost nothing.
%
% It is not enough that the pipeline survives. A dead pixel does not move with
% the tissue, and motion correction registers against whatever does not move:
% three of them collapsed a session's estimated shifts from a standard deviation
% of 2.8 pixels to 0.4, silently. So the assertions are that the scan SAW them,
% and -- in check_dark_pixel_costs_nothing -- that the aligned frame comes out
% the same size as the run without them.
C = {};
try
    C{end+1} = bm_chk_true('the dead pixels were written into the raw video', ...
        ~isempty(dark), sprintf('%d per session', size(dark(1).rc,1)));

    n_poked = size(dark(1).rc,1);
    found = zeros(1, numel(ds));
    all_hit = true; extras = zeros(1, numel(ds)); frame_px = 0;
    for i = 1:numel(ds)
        r = CaliAli_load(ds{i}, 'CaliAli_options.defects_repaired');
        if isempty(r), all_hit = false; continue; end
        found(i) = r.n_dead;
        frame_px = numel(r.dead);
        hit = arrayfun(@(k) r.dead(dark(i).rc(k,1), dark(i).rc(k,2)), 1:n_poked);
        all_hit = all_hit && all(hit);
        extras(i) = r.n_dead - sum(hit);
    end
    C{end+1} = bm_chk_true('downsampling recorded the repair', ...
        all(found > 0), sprintf('dead pixels found per session: %s', mat2str(found)));

    % EVERY poked pixel must be found. Missing one is the failure that matters:
    % a dead pixel left in place does not move with the tissue, and motion
    % correction registers against whatever does not move.
    C{end+1} = bm_chk_true('every dead pixel was found', all_hit, ...
        sprintf('%d poked per session, found %s', n_poked, mat2str(found)));

    % Extras are not required to be zero. A real recording contains pixels that
    % genuinely are anomalous, and interpolating a few isolated ones from their
    % neighbours is harmless -- where missing a real defect is not. So the bias
    % is deliberately permissive, and what is asserted is that it stays small.
    C{end+1} = bm_chk_true('it does not flag the whole sensor', ...
        max(extras) <= max(10, 0.001*frame_px), ...
        sprintf('extras per session %s, of %d pixels', mat2str(extras), frame_px));
catch ME
    C{end+1} = bm_chk_fail('dead pixel', ME.message);
end
end
