function results = bm_compare_main(results, args)
%% bm_compare_main: Run the same scenarios against a worktree of main.
%
% A worktree rather than a branch switch, so the working tree is left alone.
%
% Inputs:
%   results - The record so far.
%   args    - From bm_args.
%
% Outputs:
%   results - The same record with the other arm, the metric comparison and the
%                checks that changed state.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

out = run_against_main_in(args, results.sim);
results.main = out;
if out.ok
    results.comparison = bm_compare_arms(results.scenarios, out.results.scenarios);
    results.check_diff = bm_compare_checks(results.scenarios, out.results.scenarios);
end
end


function out = run_against_main_in(args, sim)
%% Run the same scenarios against a worktree of main.
% A worktree rather than a branch switch: the working tree is not disturbed, and
% the two arms can run one after the other unattended.
out = struct('ok',false,'error','','dir','','results',[]);
wt = fullfile(args.out_dir,'worktree_main');
try
    [st,msg] = system(sprintf('cd %s && git worktree add -f %s main 2>&1', ...
        bm_escape(args.repo), bm_escape(wt)));
    if st ~= 0, error('CaliAli:benchmark:worktree','%s', msg); end
    out.dir = wt;
    fprintf('worktree of main at %s\n', wt);
    % The harness itself lives only on this branch, so run it from here with the
    % worktree on the path instead of the current checkout.
    out.results = CaliAli_benchmark('repo', wt, ...
        'out_dir', fullfile(args.out_dir,'arm_main'), ...
        'sim_dir', sim.dir, 'scenarios', args.scenarios, ...
        'compare_main', false, 'frames', args.frames, 'sessions', args.sessions);
    out.ok = true;
catch ME
    out.error = bm_format_error(ME);
    fprintf(2,'A/B against main failed: %s\n', ME.message);
end
end
