function results = bm_new_results(args)
%% The shape of the record every stage adds to.
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
