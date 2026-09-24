function results = CaliAli_benchmark(varargin)
%% CaliAli_benchmark: Run the pipeline end to end and check that it still works.
%
% Every stage below is one call. What each one does lives in tests/+bm/, one
% function per file, so this page can be read as a description of the benchmark
% rather than as its implementation.
%
% Usage:
%   CaliAli_benchmark();                        % everything
%   CaliAli_benchmark('unit_only', true);       % the checks that need no data
%   CaliAli_benchmark('scenarios', {'A','E'});  % a subset
%   CaliAli_benchmark('compare_main', false);   % skip the A/B against main
%
% What it produces:
%   results.unit       checks that need no simulated data at all
%   results.issues     one regression per bug reported on GitHub
%   results.scenarios  one record per pipeline scenario, with checks and metrics
%   results.cross      checks that compare scenarios against each other
%   results.main       the same scenarios run against a worktree of main
%
% Author: Pablo Vergara

args = bm_args(varargin{:});
bm_setup_paths(args);
results = bm_new_results(args);

%% Checks that need nothing but the code
bm_banner('Unit checks');
results.unit = bm_unit_checks();

%% One regression per bug that was reported and fixed
bm_banner('Reported-issue regressions');
results.issues = bm_issue_checks();

if args.unit_only, results = bm_finish(results); return, end

%% One simulated recording, used by every scenario that does not ask otherwise
bm_banner('Simulation');
results.sim = bm_simulate(fullfile(args.out_dir,'simulation'), args, 0);

%% Each scenario exercises one code path end to end
results = bm_run_scenarios(results, args);

%% Checks that only make sense across scenarios
bm_banner('Cross-scenario checks');
results.cross = bm_cross_checks(results.scenarios);

%% The same scenarios on a worktree of main, to see what this branch changed
if args.compare_main
    bm_banner('A/B against main');
    results = bm_compare_main(results, args);
end

%% Report
results = bm_finish(results);
bm_report(results, args);
end
