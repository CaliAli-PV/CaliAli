function results = bm_run_scenarios(results, args)
%% Run every selected scenario, one after another, collecting its record.
%
% A scenario that throws is recorded as failed and the rest still run: the point
% of the benchmark is to find out how many things are broken, not to stop at the
% first.
scn = bm_scenarios();
if ~isempty(args.scenarios)
    scn = scn(ismember({scn.id}, args.scenarios));
end
bm_banner(sprintf('Scenarios (%d)', numel(scn)));

% Every field a record can carry, declared once. run_scenario adds fields as it
% goes, and a struct array will not accept an element whose fields differ from
% the rest, so each record is normalised against this list before being appended.
rec_fields = {'id','name','ok','error','checks','score','metrics','timing', ...
    'seconds','dir','ds_files','mc_files','aligned','extraction','dark'};

start_dir = pwd;
for i = 1:numel(scn)
    s = scn(i);
    fprintf('\n--- %s: %s ---\n', s.id, s.name);
    t0 = tic;
    rec = struct('id',s.id,'name',s.name,'ok',false,'error','', ...
        'checks',struct([]),'score',[],'metrics',struct(),'seconds',0, ...
        'dir',fullfile(args.out_dir, ['scn_' s.id]));
    try
        [sim, results] = simulation_for(s, results, args);
        rec = bm_run_scenario(s, sim, rec, args);
        rec.ok = true;
    catch ME
        rec.error = bm_format_error(ME);
        fprintf(2, '  FAILED: %s\n', ME.message);
    end
    rec.seconds = toc(t0);
    cd(start_dir);
    rec = bm_normalize_rec(rec, rec_fields);
    if isempty(results.scenarios)
        results.scenarios = rec;
    else
        results.scenarios(end+1) = rec;
    end
    fprintf('  %s in %.0f s\n', bm_tern(rec.ok,'completed','FAILED'), rec.seconds);
end
end


function [sim, results] = simulation_for(s, results, args)
%% Most scenarios share one recording. The non-rigid ones need one that actually
%% deforms, and it is built only if such a scenario is actually selected.
if strcmp(s.sim,'nonrigid')
    if ~isfield(results,'sim_nonrigid') || isempty(results.sim_nonrigid)
        bm_banner('Simulation with non-rigid motion');
        results.sim_nonrigid = bm_simulate( ...
            fullfile(args.out_dir,'simulation_nonrigid'), args, args.nonrigid_std);
    end
    sim = results.sim_nonrigid;
else
    sim = results.sim;
end
end
