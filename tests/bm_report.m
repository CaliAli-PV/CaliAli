function bm_report(r, args) %#ok<INUSD>
%% bm_report: Print what failed and what moved.
%
% Inputs:
%   r    - The finished record.
%   args - From bm_args.
%
% Outputs:
%   None.

bm_banner('Summary');
np = @(C) sum([C.pass]);
fprintf('unit checks      : %d of %d passed\n', np(r.unit), numel(r.unit));
fprintf('\n%-6s %-46s %-9s %6s %s\n','id','scenario','checks','sec','status');
fprintf('%s\n', repmat('-',1,88));
for i = 1:numel(r.scenarios)
    s = r.scenarios(i);
    if isempty(s.checks), cc = '-'; else, cc = sprintf('%d/%d', np(s.checks), numel(s.checks)); end
    fprintf('%-6s %-46s %-9s %6.0f %s\n', s.id, s.name, cc, s.seconds, ...
        bm_tern(s.ok,'ok','FAILED'));
end
% everything that did not pass, gathered in one place
fprintf('\n');
bad = false;
for i = 1:numel(r.scenarios)
    s = r.scenarios(i);
    if ~s.ok
        bad = true; fprintf(2,'%s FAILED: %s\n', s.id, s.error);
    elseif ~isempty(s.checks) && any(~[s.checks.pass])
        bad = true;
        f = s.checks(~[s.checks.pass]);
        for j = 1:numel(f)
            fprintf(2,'%s check failed: %s (%s)\n', s.id, f(j).name, f(j).detail);
        end
    end
end
if isfield(r,'cross') && ~isempty(r.cross)
    x = r.cross(~[r.cross.pass]);
    for j = 1:numel(x)
        bad = true; fprintf(2,'cross-scenario check failed: %s (%s)\n', x(j).name, x(j).detail);
    end
end
u = r.unit(~[r.unit.pass]);
for j = 1:numel(u)
    bad = true; fprintf(2,'unit check failed: %s (%s)\n', u(j).name, u(j).detail);
end
if ~bad, fprintf('Everything passed.\n'); end

%% ---- what this branch fixes, and anything it broke ----------------------
if isfield(r,'check_diff')
    bm_banner('Checks that changed against main');
    d = r.check_diff;
    if isempty(d)
        fprintf('No check changed state. Every assertion behaves the same on both.\n');
    else
        fixed = strcmp({d.verdict},'FIXED');
        fprintf('%d fixed, %d regressed\n\n', sum(fixed), sum(~fixed));
        for i = find(~fixed)   % regressions first: the only alarming outcome
            fprintf(2,'  REGRESSED  %-4s %s\n', d(i).id, d(i).name);
        end
        for i = find(fixed)
            fprintf('  fixed      %-4s %s\n', d(i).id, d(i).name);
        end
    end
end

%% ---- this branch against main ------------------------------------------
if isfield(r,'comparison') && ~isempty(r.comparison)
    bm_banner('This branch against main');
    fprintf('These changes are procedural, so every metric below is EXPECTED TO\n');
    fprintf('MATCH. A difference is the finding, not the result.\n\n');
    fprintf('%-6s %-18s %12s %12s %12s  %s\n', ...
        'scn','metric','this branch','main','delta','');
    fprintf('%s\n', repmat('-',1,78));
    c = r.comparison;
    moved = ~[c.within_tol];
    % the ones that moved first, since those are the whole point
    for i = [find(moved), find(~moved)]
        fprintf('%-6s %-18s %12.4g %12.4g %12.4g  %s\n', c(i).id, c(i).metric, ...
            c(i).this, c(i).other, c(i).delta, bm_tern(c(i).within_tol,'','<-- MOVED'));
    end
    fprintf('\n%d of %d metrics differ beyond tolerance.\n', sum(moved), numel(c));
elseif isfield(r,'main') && isstruct(r.main) && isfield(r.main,'ok') && ~r.main.ok
    % isstruct, because the field is initialised empty and stays that way when
    % compare_main is off -- indexing [] with a dot is an error, not a false.
    fprintf(2,'\nA/B against main did not run: %s\n', r.main.error);
end
end
