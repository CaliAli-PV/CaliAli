function results = bm_new_results(args)
%% bm_new_results: Initialize the record that every stage adds to.
%
% Declares each field up front so a stage can be skipped without the fields it
% would have filled going missing.
%
% Inputs:
%   args - From bm_args.
%
% Outputs:
%   results - Empty record, with the header already printed.

results = struct();
results.repo      = args.repo;
results.out_dir   = args.out_dir;
results.started   = datestr(now); %#ok<TNOW1,DATST>
results.unit      = [];
results.issues    = [];
results.sim       = [];
results.scenarios = [];
results.cross     = [];
results.main      = [];

bm_banner('CaliAli benchmark');
fprintf('repo      : %s\n', args.repo);
fprintf('out_dir   : %s\n', args.out_dir);
fprintf('started   : %s\n\n', results.started);
end
