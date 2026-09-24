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
    C{end+1} = bm_chk_true('a dark pixel costs no frame area', ...
        isequal(da(1:2), dm(1:2)), ...
        sprintf('A %s vs M %s', mat2str(da(1:2)), mat2str(dm(1:2))));
catch ME
    C{end+1} = bm_chk_fail('dark pixel cost', ME.message);
end
end
