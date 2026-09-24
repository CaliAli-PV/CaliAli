function results = CaliAli_benchmark(varargin)
%% CaliAli_benchmark: Run the CaliAli pipeline end to end and verify its output.
%
% This function simulates calcium imaging recordings whose neurons, traces and
% motion are known, runs the complete pipeline on them, and checks the
% properties that must hold at each stage. It then runs the same scenarios
% against a worktree of main, so any change in behaviour introduced by the
% current branch is visible rather than assumed.
%
% Inputs:
%   varargin - Name/value pairs specifying which parts to run and where to write
%              them. The details of every option can be found in bm_args().
%
% Outputs:
%   results - Structure containing the checks, metrics and timings of every
%             stage. Also saved as benchmark_results.mat in the output folder.
%
% Usage:
%   CaliAli_benchmark();                        % Run everything
%   CaliAli_benchmark('unit_only', true);       % Only the checks needing no data
%   CaliAli_benchmark('scenarios', {'A','E'});  % Only the selected scenarios
%   CaliAli_benchmark('compare_main', false);   % Skip the comparison against main
%
% Steps:
%   1. Runs the unit checks, which need no simulated data.
%   2. Runs one regression per bug reported on GitHub.
%   3. Simulates one recording with known neurons, traces and motion.
%   4. Runs each scenario end to end and checks what it produced.
%   5. Compares the scenarios against each other.
%   6. Runs the same scenarios against a worktree of main.
%   7. Reports every check that failed and every metric that moved.
%
% Notes:
%   - Each scenario exercises one code path: batching (A, B, C), output datatype
%     (D1, D2), motion correction done elsewhere (E), non-rigid correction (F,
%     F1, F2), background model (G1, G2), patch geometry (H), projections (I1,
%     I2), dropped frames (J), missing options (K), settings propagation (L) and
%     sensor defects (M).
%   - Every scenario is checked for datatype, frame bookkeeping, alignment
%     quality and F1 against the ground truth, and is timed stage by stage.
%   - A scenario that fails does not stop the others. The point is to find how
%     many things are broken, not to stop at the first one.
%   - Each step below is one call. What it does can be found in the matching
%     bm_* function, one per file, in this folder.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

% Process options and prepare the output folder
args = bm_args(varargin{:});

% Put the repository under test on the path, and nothing that could shadow it
bm_setup_paths(args);

% Initialize the record every stage adds to
results = bm_new_results(args);

% Run the checks that need nothing but the code
bm_banner('Unit checks');
results.unit = bm_unit_checks();

% Run one regression per bug that was reported and fixed
bm_banner('Reported-issue regressions');
results.issues = bm_issue_checks();

% Stop here if only the data-free checks were requested
if args.unit_only
    results = bm_finish(results);
    return
end

% Simulate the recording every scenario uses unless it asks for another
bm_banner('Simulation');
results.sim = bm_simulate(fullfile(args.out_dir, 'simulation'), args, 0);

% Run each scenario end to end and check what it produced
results = bm_run_scenarios(results, args);

% Compare the scenarios against each other
bm_banner('Cross-scenario checks');
results.cross = bm_cross_checks(results.scenarios);

% Run the same scenarios against a worktree of main
if args.compare_main
    bm_banner('A/B against main');
    results = bm_compare_main(results, args);
end

% Save the record and report what failed and what moved
results = bm_finish(results);
bm_report(results, args);

end
