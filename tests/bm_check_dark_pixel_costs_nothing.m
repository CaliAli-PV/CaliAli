function C = bm_check_dark_pixel_costs_nothing(scenarios)
%% bm_check_dark_pixel_costs_nothing: A dead pixel must cost no frame area.
%
% M is A with a few genuinely dark pixels. If M's aligned frame is smaller, a zero
% is still being read as a missing pixel somewhere, and everything between it and
% the frame edge went with it.
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
try
    have = @(x) any(strcmp({scenarios.id},x) & [scenarios.ok]);
    if ~(have('A') && have('M'))
        return   % nothing to compare; not a failure
    end
    a = scenarios(strcmp({scenarios.id},'A'));
    m = scenarios(strcmp({scenarios.id},'M'));
    da = get_data_dimension(a.aligned);
    dm = get_data_dimension(m.aligned);
    % Area, with a small tolerance, rather than identical dimensions. Repairing
    % a pixel changes the data slightly, so motion correction lands on a
    % slightly different crop -- in one run M came out larger on one axis and
    % smaller on the other. What must not happen is LOSING field of view.
    area_a = da(1)*da(2); area_m = dm(1)*dm(2);
    C{end+1} = bm_chk_true('a dark pixel costs no frame area', ...
        area_m >= 0.98*area_a, ...
        sprintf('A %s = %d px, M %s = %d px (%.1f%%)', mat2str(da(1:2)), area_a, ...
        mat2str(dm(1:2)), area_m, 100*area_m/area_a));

catch ME
    C{end+1} = bm_chk_fail('dark pixel cost', ME.message);
end
end
