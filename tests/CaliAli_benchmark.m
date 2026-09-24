function results = CaliAli_benchmark(varargin)
%% CaliAli_benchmark: Run the whole pipeline on one simulated recording and check it.
%
% WHAT THIS IS FOR. Nearly every recent change to this pipeline is PROCEDURAL --
% file handling, datatypes, masks, batching, workspace hygiene -- rather than a
% change to what the algorithm computes. Those changes break things quietly: a
% recording silently cast to the wrong type, a mask that crops too much, a cached
% file reused with the wrong frame count. None of that shows up as an error.
%
% So this does not try to measure extraction quality across parameters. It runs
% ONE simulated recording with default neuron settings through every distinct
% CODE PATH, and asserts the things that should hold regardless of the data.
% Ground-truth F1 is computed as well, but mainly as a guard that a procedural
% change has not quietly wrecked the result.
%
% USAGE
%   results = CaliAli_benchmark();                    % every scenario, this repo
%   results = CaliAli_benchmark('scenarios', {'A','D'});
%   results = CaliAli_benchmark('out_dir', '/data/bench');
%   results = CaliAli_benchmark('repo', '/path/to/other/checkout');
%   results = CaliAli_benchmark('compare_main', true);  % A/B against main
%
% OPTIONS
%   out_dir      where to work. Default: a timestamped folder under tempdir.
%   scenarios    cell of scenario letters to run. Default: all.
%   repo         which CaliAli checkout to put on the path. Default: the one
%                this file lives in. Used by the A/B comparison.
%   compare_main create a git worktree of main, run the same scenarios there,
%                and report both arms side by side.
%   sim_dir      reuse an existing simulation instead of generating one.
%   frames       frames per session. Default 500.
%   sessions     number of sessions. Default 3.
%
% Every scenario runs inside a try/catch: a failure is recorded with its error
% and stack and the run continues, so one pass tells you everything that is
% broken rather than only the first thing.
%
% Author: Pablo Vergara

p = inputParser;
p.addParameter('out_dir', '');
p.addParameter('scenarios', {});
p.addParameter('repo', '');
p.addParameter('compare_main', true);
p.addParameter('sim_dir', '');
p.addParameter('frames', 500);
p.addParameter('sessions', 3);
p.addParameter('simulator', '/mnt/nasferatus/CaliAli/simulator/Simulate_Ca_Imaging_video_1.22/Simulate_Ca_Imaging_video');
p.addParameter('metrics', '/mnt/nasferatus/CaliAli/benchmark/metrics');
p.addParameter('unit_only', false);   % run the unit checks and stop: no simulation, no pipeline
p.addParameter('nonrigid_std', 3);    % deformation amplitude for the non-rigid scenarios, in pixels
p.parse(varargin{:});
args = p.Results;

if isempty(args.repo)
    args.repo = fileparts(fileparts(mfilename('fullpath')));   % repo root
end
if isempty(args.out_dir)
    args.out_dir = fullfile(tempdir, ['CaliAli_benchmark_' datestr(now,'yymmdd_HHMMSS')]); %#ok<TNOW1,DATST>
end
if ~isfolder(args.out_dir), mkdir(args.out_dir); end

start_dir = pwd;
cleanup = onCleanup(@() cd(start_dir));   % the simulator and CNMF-e both cd

banner('CaliAli benchmark');
fprintf('repo      : %s\n', args.repo);
fprintf('out_dir   : %s\n', args.out_dir);
fprintf('started   : %s\n\n', datestr(now)); %#ok<TNOW1,DATST>

setup_paths(args.repo, args.simulator, args.metrics);

results = struct();
results.repo = args.repo;
results.out_dir = args.out_dir;
results.started = datestr(now); %#ok<TNOW1,DATST>

%% ---- unit checks: no pipeline, no simulation ---------------------------
banner('Unit checks');
results.unit = run_unit_checks();
if args.unit_only
    results.finished = datestr(now); %#ok<TNOW1,DATST>
    return
end

%% ---- one simulated recording -------------------------------------------
banner('Simulation');
if isempty(args.sim_dir)
    results.sim = make_simulation(fullfile(args.out_dir,'simulation'), args);
else
    results.sim = load_simulation(args.sim_dir);
end
fprintf('videos : %d sessions\nmeta   : %s\n', numel(results.sim.files), results.sim.meta);

%% ---- scenarios ----------------------------------------------------------
scn = scenario_table();
if ~isempty(args.scenarios)
    keep = ismember({scn.id}, args.scenarios);
    scn = scn(keep);
end
banner(sprintf('Scenarios (%d)', numel(scn)));
% Every field a scenario record can carry, declared once. run_scenario adds
% fields as it goes, and a struct array will not accept an element whose fields
% differ from the rest, so each record is normalised against this list before
% being appended.
rec_fields = {'id','name','ok','error','checks','score','metrics','timing', ...
    'seconds','dir','ds_files','mc_files','aligned','extraction'};
results.scenarios = [];

for i = 1:numel(scn)
    s = scn(i);
    fprintf('\n--- %s: %s ---\n', s.id, s.name);
    t0 = tic;
    rec = struct('id',s.id,'name',s.name,'ok',false,'error','', ...
        'checks',struct([]),'score',[],'metrics',struct(),'seconds',0, ...
        'dir',fullfile(args.out_dir, ['scn_' s.id]));
    try
        if strcmp(s.sim,'nonrigid')
            if ~isfield(results,'sim_nonrigid') || isempty(results.sim_nonrigid)
                banner('Simulation with non-rigid motion');
                results.sim_nonrigid = make_simulation( ...
                    fullfile(args.out_dir,'simulation_nonrigid'), args, args.nonrigid_std);
            end
            use_sim = results.sim_nonrigid;
        else
            use_sim = results.sim;
        end
        rec = run_scenario(s, use_sim, rec, args);
        rec.ok = true;
    catch ME
        rec.error = format_error(ME);
        fprintf(2, '  FAILED: %s\n', ME.message);
    end
    rec.seconds = toc(t0);
    cd(start_dir);
    rec = normalize_rec(rec, rec_fields);
    if isempty(results.scenarios)
        results.scenarios = rec;
    else
        results.scenarios(end+1) = rec; %#ok<AGROW>
    end
    fprintf('  %s in %.0f s\n', tern(rec.ok,'completed','FAILED'), rec.seconds);
end

%% ---- checks that span scenarios -----------------------------------------
banner('Cross-scenario checks');
bi = check_batch_invariance(results.scenarios);
dp = check_dark_pixel_costs_nothing(results.scenarios);
nr = check_non_rigid_helps(results.scenarios);
nh = check_non_rigid_does_no_harm(results.scenarios);
results.cross = [bi{:}, dp{:}, nr{:}, nh{:}];
print_checks(results.cross);

%% ---- A/B against main ---------------------------------------------------
if args.compare_main
    banner('A/B against main');
    results.main = run_against_main(args, results.sim);
    if results.main.ok
        results.comparison = compare_arms(results.scenarios, results.main.results.scenarios);
        results.check_diff = compare_checks(results.scenarios, results.main.results.scenarios);
    end
end

%% ---- report -------------------------------------------------------------
results.finished = datestr(now); %#ok<TNOW1,DATST>
print_report(results);
save(fullfile(args.out_dir,'benchmark_results.mat'), 'results', '-v7.3');
fprintf('\nresults saved to %s\n', fullfile(args.out_dir,'benchmark_results.mat'));
end


%% ========================================================================
%  Scenarios
%  ========================================================================
function scn = scenario_table()
%% Each scenario is a set of option overrides plus the checks it enables.
% The point of each is a CODE PATH, not a parameter value.
scn = struct('id',{},'name',{},'opts',{},'checks',{},'mc',{},'sim',{});

scn(end+1) = mk('A','baseline, whole recording in one batch', ...
    {'downsampling.batch_sz',0}, ...
    {'dtype','offset','mask','bookkeeping','alignment','workspace','gt'}, true);

scn(end+1) = mk('B','chunked downsampling and intra-session batches', ...
    {'downsampling.batch_sz',250,'motion_correction.batch_sz',250}, ...
    {'dtype','bookkeeping','alignment','gt','batch_invariance'}, true);

scn(end+1) = mk('C','automatic batch size', ...
    {'downsampling.batch_sz','auto'}, ...
    {'dtype','bookkeeping','gt','batch_invariance'}, true);

scn(end+1) = mk('D1','datatype uint8', ...
    {'downsampling.batch_sz',0,'downsampling.output_class','uint8'}, ...
    {'dtype','bookkeeping'}, true);

scn(end+1) = mk('D2','datatype single', ...
    {'downsampling.batch_sz',0,'downsampling.output_class','single'}, ...
    {'dtype','bookkeeping'}, true);

% Motion correction done OUTSIDE CaliAli. Each session is corrected on its own
% and then stripped of every record of how, which is what a file coming back from
% CaImAn or Suite2p looks like: corrected, cropped to its own valid region, and
% carrying nothing that says where that region sat in the original frame. The
% sessions therefore arrive at different sizes AND off centre from each other,
% which is what alignment has to reconcile.
%
% This used to be spelled 'mc = false', which skipped motion correction without
% substituting anything, so the scenario ran the whole pipeline on data with
% 3-pixel jitter still in it. That dominated every number it produced -- crispness
% 5.47 against A's 8.55, F1 0.498 against 0.730 -- and told us nothing about the
% path it was meant to exercise.
scn(end+1) = mk('E','motion correction done outside CaliAli', ...
    {'downsampling.batch_sz',0}, ...
    {'dtype','bookkeeping','alignment','gt','sizes'}, 'external');

% Non-rigid correction, on a recording that actually deforms. These two are a
% matched pair on the SAME simulation and differ only in do_non_rigid, which is
% the only way to say whether the correction helps. Run against the default
% recording, whose within-session motion is pure translation, the non-rigid pass
% has nothing to find and every patch shift it estimates is noise -- it can only
% lose. The comparison is made in check_non_rigid_helps.
% THE NULL TEST, and the one that gates the others. This is scenario A with
% do_non_rigid switched on, on the SAME recording, whose within-session motion is
% pure translation. There is no deformation to correct, so a correctly
% parameterised patch correction must estimate almost nothing and leave the
% result where rigid alone left it. If it cannot do no harm here, no amount of
% rescuing elsewhere makes it safe to enable.
scn(end+1) = mk('F','non-rigid on a recording that does not deform', ...
    {'downsampling.batch_sz',0,'motion_correction.do_non_rigid',true}, ...
    {'mask','bookkeeping','alignment','gt'}, true);

scn(end+1) = mk('F1','deforming recording, translation only', ...
    {'downsampling.batch_sz',0,'motion_correction.do_non_rigid',false}, ...
    {'mask','bookkeeping','alignment','gt'}, true, 'nonrigid');

scn(end+1) = mk('F2','deforming recording, translation and non-rigid', ...
    {'downsampling.batch_sz',0,'motion_correction.do_non_rigid',true}, ...
    {'mask','bookkeeping','alignment','gt'}, true, 'nonrigid');

% batch_sz is set flat, not on inter_session_alignment alone: parameters live in
% one namespace and are copied into every module, so a per-module value is
% discarded. These two need more than one frame batch to reach the parfor path
% in update_temporal_CaliAli, and only a flat value delivers that.
scn(end+1) = mk('G1','background nmf, parallel (reaches the parfor fix)', ...
    {'downsampling.batch_sz',250,'cnmf.background_model','nmf', ...
     'cnmf.use_parallel',true}, ...
    {'bookkeeping','gt'}, true);

scn(end+1) = mk('G2','background svd, parallel', ...
    {'downsampling.batch_sz',250,'cnmf.background_model','svd', ...
     'cnmf.use_parallel',true}, ...
    {'bookkeeping','gt'}, true);

scn(end+1) = mk('H','patch geometry 32x32 (w_overlap derived)', ...
    {'downsampling.batch_sz',0}, {'bookkeeping','gt','patch'}, true);

scn(end+1) = mk('I1','fast PNR projections', ...
    {'downsampling.batch_sz',0,'preprocessing.fastPNR',true}, ...
    {'bookkeeping','alignment'}, true);

scn(end+1) = mk('I2','neuron enhancement off', ...
    {'downsampling.batch_sz',0,'preprocessing.neuron_enhance',false}, ...
    {'bookkeeping','alignment'}, true);

scn(end+1) = mk('J','dropped frame is detected and interpolated', ...
    {'downsampling.batch_sz',0}, {'dropped'}, true);

% A file whose CaliAli_options were lost -- hand-edited, produced by an older
% version, or written by something else. The requirement is not that it works,
% it is that it FAILS LOUDLY rather than continuing with silent defaults.
scn(end+1) = mk('K','a file with no CaliAli_options must complain', ...
    {'downsampling.batch_sz',0}, {'missing_options'}, false);

% A dark pixel in the middle of the field of view. Every border in this pipeline
% used to be found by treating the value 0 as "filled by a translation", so a
% pixel that is genuinely 0 was indistinguishable from one that is missing, and
% got cropped away with everything between it and the frame edge. The valid
% region now comes from the transform instead, so this must cost nothing: same
% options as A, same simulation, and the aligned frame must come out the same
% size. Anything smaller means a value is still being read as absence.
scn(end+1) = mk('M','a dark pixel in the field of view costs nothing', ...
    {'downsampling.batch_sz',0}, ...
    {'dtype','bookkeeping','alignment','gt','darkpixel'}, true);

% Settings must reach the stage that uses them, and be recorded in what it
% writes. A parameter that is quietly ignored is indistinguishable from one that
% was never set.
scn(end+1) = mk('L','settings propagate into the files that stages write', ...
    {'downsampling.batch_sz',0,'downsampling.spatial_ds',2, ...
     'downsampling.output_class','uint8'}, {'propagation'}, true);
end

function s = mk(id,name,opts,checks,mc,sim)
%% SIM names which simulated recording the scenario runs on. Almost everything
% uses the default one; the non-rigid scenarios need a recording that actually
% deforms, which the default deliberately does not.
if nargin < 6 || isempty(sim), sim = 'default'; end
s = struct('id',id,'name',name,'opts',{opts},'checks',{checks},'mc',mc,'sim',sim);
end


function rec = run_scenario(s, sim, rec, args)
%% One scenario: its own directory, its own copy of the inputs, its own options.
% A fresh directory per scenario is not tidiness. detrend_batch_and_calculate_
% projections reuses a cached _det.mat AND READS THE OPTIONS BACK OUT OF IT, so
% two scenarios sharing a folder silently inherit each other's settings. And
% CaliAli_motion_correction errors when every input is already processed, so a
% second run over the same folder cannot work at all.
if isfolder(rec.dir), rmdir(rec.dir,'s'); end
mkdir(rec.dir);

files = copy_inputs(sim.files, rec.dir);
if strcmp(s.id,'J')
    files = blank_one_frame(files);   % the dropped frame this scenario looks for
end
if strcmp(s.id,'M')
    rec.dark = poke_dark_pixels(files);   % dead pixels in the RAW recording
end

opt = CaliAli_demo_parameters();
opt = apply_overrides(opt, s.opts);
if strcmp(s.id,'H')
    opt.cnmf.pars_envs.patch_dims = [32 32];
    opt.cnmf.pars_envs.w_overlap = [];       % let it be derived
end

C = {};   % checks accumulate here

if strcmp(s.id,'K')
    kc = check_missing_options(files, rec.dir);
    rec.checks = [kc{:}];
    rec.metrics = struct();
    print_checks(rec.checks);
    return
end

% Each stage is timed. These changes are procedural, and several of them touch
% how much is read from disk and how much is held in memory, so a stage getting
% slower or faster is a result in its own right -- and the kind that no
% correctness check would ever notice.
T = struct();

%% 1. downsample
t = tic;
opt.downsampling.input_files = files;
opt = CaliAli_downsample(opt);
T.downsample = toc(t);
ds = opt.downsampling.output_files;
rec.ds_files = ds;

%% 2. motion correction
% Three cases. true: CaliAli corrects all the sessions together, which is the
% normal path. 'external': each session is corrected on its own and then stripped
% of the record, standing in for a different tool. false: not corrected at all,
% which is only ever right for a scenario that stops before extraction.
t = tic;
if isequal(s.mc, true)
    opt.motion_correction.input_files = ds;
    opt = CaliAli_motion_correction(opt);
    mc = opt.motion_correction.output_files;
elseif ischar(s.mc) && strcmp(s.mc,'external')
    mc = correct_each_session_alone(ds, opt);
else
    mc = ds;
end
T.motion_correction = toc(t);
rec.mc_files = mc;

%% 3. alignment
t = tic;
opt.inter_session_alignment.input_files = column_cell(mc);
sentinel = rand(3);
assignin('base','caliali_benchmark_sentinel',sentinel);
opt = CaliAli_align_sessions(opt);
T.alignment = toc(t);
aligned = opt.inter_session_alignment.out_aligned_sessions;
rec.aligned = aligned;

%% 4. extraction
t = tic;
files_out = CaliAli_cnmfe(aligned);
T.extraction = toc(t);
if iscell(files_out), extraction = files_out{1}; else, extraction = files_out; end
rec.extraction = extraction;

T.total = T.downsample + T.motion_correction + T.alignment + T.extraction;
rec.timing = T;
fprintf('  timing: downsample %.0fs | motion %.0fs | align %.0fs | extract %.0fs\n', ...
    T.downsample, T.motion_correction, T.alignment, T.extraction);

%% ---- checks -------------------------------------------------------------
if has(s.checks,'dtype'),       C = [C, check_dtype(opt, ds, mc, aligned)]; end
if has(s.checks,'offset'),      C = [C, check_no_offset(ds, mc, opt)]; end
if has(s.checks,'mask'),        C = [C, check_mask(opt)]; end
if has(s.checks,'bookkeeping'), C = [C, check_bookkeeping(opt, aligned)]; end
if has(s.checks,'alignment'),   C = [C, check_alignment(opt, aligned)]; end
if has(s.checks,'workspace'),   C = [C, check_workspace(sentinel)]; end
if has(s.checks,'patch'),       C = [C, check_patch(opt)]; end
if has(s.checks,'dropped'),     C = [C, check_dropped(rec.dir, 10)]; end
if has(s.checks,'sizes'),       C = [C, check_size_reconciliation(mc, aligned, opt)]; end
if has(s.checks,'darkpixel'), C = [C, check_dark_pixels(ds, aligned, rec.dark)]; end
if has(s.checks,'propagation'), C = [C, check_propagation(opt, ds, aligned, sim)]; end
if has(s.checks,'gt')
    [gt_checks, rec.score] = check_ground_truth(extraction, sim, opt);
    C = [C, gt_checks];
end

% Everything numeric worth comparing against the other arm, in one flat struct.
rec.metrics = collect_metrics(opt, rec.score, rec.timing);

rec.checks = [C{:}];
print_checks(rec.checks);
end


%% ========================================================================
%  Checks that need no ground truth
%  ========================================================================
function C = check_dtype(opt, ds, mc, aligned)
%% The configured class must survive every stage.
% Except the detrended file: get_projections_and_detrend deliberately forces
% uint16 there, so that one is asserted to BE uint16 rather than to match.
want = 'uint16';
try want = lower(char(opt.downsampling.output_class)); catch; end
C = {};
C{end+1} = chk('dtype: _ds.mat', mat_class(ds{1}), want);
if ~isequal(ds, mc)
    C{end+1} = chk('dtype: _mc.mat', mat_class(mc{1}), want);
end
C{end+1} = chk('dtype: _Aligned.mat is uint16 by design', mat_class(aligned), 'uint16');
end

function C = check_no_offset(ds, mc, opt)
%% No stage may shift the whole recording by a constant.
% The pipeline used to add 1 in two places so that 0 could mean "border fill".
% Nothing subtracted it, so the data carried a permanent offset.
C = {};
if isequal(ds, mc), return; end
try
    a = read_frame(ds{1}, 1);
    b = read_frame(mc{1}, 1);
    m = opt.motion_correction.Mask;
    if ~isempty(m) && isequal(size(m), size(b))
        inside = logical(m);
        % compare only where both hold real data
        da = double(a(inside)); db = double(b(inside));
        shift = median(db) - median(da);
        C{end+1} = chk_num('offset introduced by motion correction', shift, 0, 0.5);
    end
catch ME
    C{end+1} = chk_fail('offset', ME.message);
end
end

function C = check_mask(opt)
%% The valid region must be a real rectangle that excludes something.
C = {};
m = [];
try m = opt.motion_correction.Mask; catch; end
if isempty(m)
    C{end+1} = chk_fail('mask exists', 'motion_correction.Mask is empty');
    return
end
m = logical(m);
frac = nnz(m)/numel(m);
C{end+1} = chk_true('mask covers most of the frame', frac > 0.5, sprintf('%.3f', frac));
C{end+1} = chk_true('mask excludes the translated border', frac < 1, sprintf('%.3f', frac));
% a rectangle: its bounding box has the same count as the mask itself
[r,c] = find(m);
box = (max(r)-min(r)+1)*(max(c)-min(c)+1);
C{end+1} = chk_true('mask is a rectangle', box == nnz(m), sprintf('%d vs %d', box, nnz(m)));
end

function C = check_bookkeeping(opt, aligned)
%% Frames must be conserved, and alignment must declare itself finished.
C = {};
isa_ = opt.inter_session_alignment;
try
    C{end+1} = chk_true('input_F equals detrend_F', ...
        isequal(isa_.input_F(:), isa_.detrend_F(:)), ...
        sprintf('%s vs %s', mat2str(isa_.input_F(:)'), mat2str(isa_.detrend_F(:)')));
catch
    C{end+1} = chk_fail('input_F equals detrend_F', 'field missing');
end
try
    d = get_data_dimension(aligned);
    C{end+1} = chk_num('aligned frame count equals sum of sessions', ...
        d(3), sum(isa_.F), 0);
catch ME
    C{end+1} = chk_fail('aligned frame count', ME.message);
end
try
    done = CaliAli_load(aligned,'alignment_completed');
    C{end+1} = chk_true('alignment_completed', isequal(done,true), '');
catch
    C{end+1} = chk_fail('alignment_completed', 'flag missing');
end
end

function C = check_alignment(opt, aligned)
%% The alignment metrics must improve, and the vessel score must clear its gate.
C = {};
isa_ = opt.inter_session_alignment;
try
    t = isa_.alignment_metrics;
    score = t.("Mean Corr. Score");
    if iscell(score), score = cell2mat(score); end
    C{end+1} = chk_true('alignment improves correlation', ...
        all(diff(score) >= -1e-6), mat2str(score(:)',4));
catch ME
    C{end+1} = chk_fail('alignment_metrics', ME.message);
end
try
    bv = isa_.BV_score;
    % Below 2.7 the whole alignment is redone from neurons instead of vessels.
    % That is a different branch, so any comparison against another arm stops
    % being meaningful -- worth knowing about rather than silently passing.
    C{end+1} = chk_true('BV_score above the neuron-fallback gate', bv >= 2.7, ...
        sprintf('%.2f', bv));
catch ME
    C{end+1} = chk_fail('BV_score', ME.message);
end
% Cn, Cn_scale, PNR and the per-session projections are written by
% save_relevant_variables, which takes CaliAli_options BY VALUE and returns
% nothing. They exist only in the saved file, never in the struct the caller
% gets back -- so they have to be read from the file.
try
    stored = CaliAli_load(aligned, 'CaliAli_options');
    sa = stored.inter_session_alignment;
    C{end+1} = chk_num('per-session projections recorded', ...
        numel(sa.Cn_scale_per_session), numel(sa.F), 0);
    C{end+1} = chk_num('per-session images recorded', ...
        size(sa.Cn_per_session,3), numel(sa.F), 0);
    C{end+1} = chk_true('projection method recorded', ...
        ischar(sa.projection_method) && ~isempty(sa.projection_method), ...
        char(sa.projection_method));
    C{end+1} = chk_true('per-session peaks are positive', ...
        all(sa.Cn_scale_per_session > 0), mat2str(sa.Cn_scale_per_session(:)',4));
catch ME
    C{end+1} = chk_fail('per-session projections', ME.message);
end
end

function C = check_workspace(sentinel)
%% The pipeline must not create or destroy variables in the base workspace.
C = {};
try
    still = evalin('base','exist(''caliali_benchmark_sentinel'',''var'')');
    C{end+1} = chk_true('base workspace variable survived', still==1, '');
    if still==1
        got = evalin('base','caliali_benchmark_sentinel');
        C{end+1} = chk_true('base workspace variable unchanged', isequal(got,sentinel), '');
    end
    names = evalin('base','who');
    leaked = names(startsWith(names,'mat_data'));
    C{end+1} = chk_true('no mat_data_* left in base', isempty(leaked), strjoin(leaked',','));
    evalin('base','clear caliali_benchmark_sentinel');
catch ME
    C{end+1} = chk_fail('base workspace', ME.message);
end
end

function C = check_patch(opt)
%% w_overlap follows patch_dims instead of being a fixed 32.
C = {};
try
    pe = opt.cnmf.pars_envs;
    C{end+1} = chk_num('w_overlap derived from patch_dims', ...
        pe.w_overlap, round(0.5*min(pe.patch_dims)), 0);
catch ME
    C{end+1} = chk_fail('w_overlap', ME.message);
end
end

function C = check_dropped(scn_dir, blanked_idx)
%% A frame the camera never delivered must be found and interpolated.
%
% The test has to DISCRIMINATE between the two arms, which an "is any frame all
% zero" test does not: on main the offset turned a dropped frame into a frame of
% ones, so no all-zero frame survives there either and such a test passes for the
% wrong reason.
%
% An untouched dropped frame is CONSTANT, whatever constant it holds. An
% interpolated one carries the structure of its neighbours. So the discriminating
% measurement is the spatial variance of that one frame.
C = {};
f = dir(fullfile(scn_dir,'*_mc.mat'));
if isempty(f)
    C{end+1} = chk_fail('dropped frame', 'no _mc.mat produced');
    return
end
try
    m = matfile(fullfile(f(1).folder,f(1).name));
    w = whos(m,'Y');
    if blanked_idx > w.size(3)
        C{end+1} = chk_fail('dropped frame', 'blanked frame is outside the output');
        return
    end
    fr = double(m.Y(:,:,blanked_idx));
    neighbours = double(m.Y(:,:,max(1,blanked_idx-1)));
    sd = std(fr(:));
    C{end+1} = chk_true('dropped frame was interpolated, not left flat', sd > 0, ...
        sprintf('std %.3f (0 means untouched)', sd));
    C{end+1} = chk_true('interpolated frame resembles its neighbour', ...
        sd == 0 || corr(fr(:), neighbours(:)) > 0.5, ...
        sprintf('corr %.3f', corr(fr(:), neighbours(:))));
catch ME
    C{end+1} = chk_fail('dropped frame', ME.message);
end
end

function [C, score] = check_ground_truth(extraction, sim, opt)
%% Score the extraction against what was simulated.
C = {}; score = [];
try
    L = load(extraction,'neuron');
    n = L.neuron;
    nrn = struct('A',n.A,'C',n.C,'C_raw',n.C_raw, ...
        'options',struct('d1',n.options.d1,'d2',n.options.d2));
    % Explicit factors: evaluate_extraction cannot read them off a plain struct
    % and would silently assume 1.
    r = evaluate_extraction(nrn, sim.meta, 'trace','C', ...
        'spatial_ds', opt.downsampling.spatial_ds, ...
        'temporal_ds', opt.downsampling.temporal_ds, ...
        'per_session', true, 'verbose', false);
    score = struct('auc_f1',r.auc_f1,'auc_precision',r.auc_precision, ...
        'auc_recall',r.auc_recall,'n_extracted',r.n_extracted_total, ...
        'n_gt',r.n_gt_total,'per_session',[r.per_session.auc_f1]);
    C{end+1} = chk_true('extraction found components', r.n_extracted_total > 0, ...
        sprintf('%d', r.n_extracted_total));
    % No absolute threshold is asserted here. These changes are procedural, so
    % the meaningful question is not "is F1 good" but "is F1 the same as it was
    % on main". That comparison happens in compare_arms, against the other arm
    % of the same scenario on the same simulated recording.
catch ME
    C{end+1} = chk_fail('ground truth scoring', ME.message);
end
end


%% ========================================================================
%  Unit checks
%  ========================================================================
function U = run_unit_checks()
C = {};
C = [C, unit_check_mat_video()];
C = [C, unit_parameters()];
C = [C, unit_parameter_divergence()];
C = [C, unit_batch_modes()];
C = [C, unit_translation_bound()];
C = [C, unit_w_overlap()];
C = [C, unit_mat_data_cache()];
U = [C{:}];
print_checks(U);
end

function C = unit_check_mat_video()
%% The file-integrity test decides whether a file gets DELETED, so a false
% positive loses data. The old rule was a size threshold, which deleted a valid
% small recording and kept a large truncated one.
C = {};
d = tempname; mkdir(d);
try
    Y = uint16(rand(8,8,20)*1000+1); save(fullfile(d,'good.mat'),'Y','-v7.3');
    Y = uint16(rand(8,8)*1000+1);    save(fullfile(d,'flat.mat'),'Y','-v7.3');
    Y = uint16(rand(8,8,20)*1000+1); Y(:,:,end)=0; save(fullfile(d,'cut.mat'),'Y','-v7.3');
    Y = uint16(rand(1,1,3)*1000+1);  save(fullfile(d,'tiny.mat'),'Y','-v7.3');   %#ok<NASGU>

    C{end+1} = chk('check_mat_video: complete file', check_mat_video(fullfile(d,'good.mat')), 'ok');
    C{end+1} = chk('check_mat_video: Y not 3-D',     check_mat_video(fullfile(d,'flat.mat')), 'corrupt');
    C{end+1} = chk('check_mat_video: truncated',     check_mat_video(fullfile(d,'cut.mat')),  'corrupt');
    C{end+1} = chk('check_mat_video: small but valid', check_mat_video(fullfile(d,'tiny.mat')), 'ok');
    C{end+1} = chk('check_mat_video: missing',       check_mat_video(fullfile(d,'nope.mat')), 'missing');
    C{end+1} = chk('check_mat_video: wrong frame count', ...
        check_mat_video(fullfile(d,'good.mat'), 999), 'corrupt');

    % deleting must be confined to what is genuinely broken
    remove_corrupted_output({fullfile(d,'tiny.mat'), fullfile(d,'cut.mat')});
    C{end+1} = chk_true('remove_corrupted_output keeps the valid small file', ...
        isfile(fullfile(d,'tiny.mat')), '');
    C{end+1} = chk_true('remove_corrupted_output deletes the truncated file', ...
        ~isfile(fullfile(d,'cut.mat')), '');

    % reporting must never delete
    Y = uint16(rand(8,8,20)*1000+1); Y(:,:,end)=0; save(fullfile(d,'cut2.mat'),'Y','-v7.3'); %#ok<NASGU>
    bad = report_corrupted_files({fullfile(d,'cut2.mat')});
    C{end+1} = chk_true('report_corrupted_files deletes nothing', ...
        isfile(fullfile(d,'cut2.mat')) && numel(bad)==1, '');
catch ME
    C{end+1} = chk_fail('check_mat_video unit', ME.message);
end
rmdir(d,'s');
end

function C = unit_parameters()
%% Name/value pairs were flattened into a column, so with two or more pairs the
% names and values interleaved. One pair happened to work, which is why it
% survived: a single-pair test proves nothing.
C = {};
try
    o = CaliAli_parameters('batch_sz', 250, 'spatial_ds', 2);
    C{end+1} = chk_num('two name/value pairs: batch_sz', o.downsampling.batch_sz, 250, 0);
    C{end+1} = chk_num('two name/value pairs: spatial_ds', o.downsampling.spatial_ds, 2, 0);
catch ME
    C{end+1} = chk_fail('two name/value pairs', ME.message);
end
try
    CaliAli_parameters('batch_sz');
    C{end+1} = chk_fail('odd argument count rejected', 'no error raised');
catch
    C{end+1} = chk_true('odd argument count rejected', true, '');
end
try
    o = CaliAli_parameters();
    o.inter_session_alignment.Cn_scale_per_session = [0.2;0.3];
    o.inter_session_alignment.projection_method = 'greedy';
    o2 = CaliAli_parameters(o);
    C{end+1} = chk_true('new projection fields survive a round trip', ...
        isequal(o2.inter_session_alignment.Cn_scale_per_session,[0.2;0.3]) && ...
        strcmp(o2.inter_session_alignment.projection_method,'greedy'), '');
catch ME
    C{end+1} = chk_fail('projection fields round trip', ME.message);
end
end

function C = unit_parameter_divergence()
%% A value set on one module must be honoured, and a flat one must propagate.
%
% These used to be in conflict. Parameters live in a flat namespace that is
% projected into one substructure per module, and the projection used to be
% collapsed on every parse, so a per-module setting was silently discarded --
% setting inter_session_alignment.batch_sz left it at 'auto' and said nothing.
% Both now work, which needs four tiers of precedence and one rule: an EMPTY
% top-level value is the seed a parameter started with, not a setting, so it
% never overrides. gSig arrives as [] and is derived by downsampling; without
% that rule the original [] would win and undo every derivation.
C = {};
try
    base = CaliAli_demo_parameters();

    o = base; o.motion_correction.batch_sz = 250;
    r = CaliAli_parameters(o);
    C{end+1} = chk_num('a per-module value is honoured', ...
        r.motion_correction.batch_sz, 250, 0);
    C{end+1} = chk_true('and does not leak to the other modules', ...
        ~isequal(r.inter_session_alignment.batch_sz, 250), ...
        num2str(r.inter_session_alignment.batch_sz));

    o = base; o.batch_sz = 250;
    r = CaliAli_parameters(o);
    C{end+1} = chk_true('a top-level value still reaches every module', ...
        isequal(r.downsampling.batch_sz,250) && ...
        isequal(r.motion_correction.batch_sz,250) && ...
        isequal(r.inter_session_alignment.batch_sz,250), '');

    r = CaliAli_parameters(base, 'batch_sz', 700);
    C{end+1} = chk_true('a name/value pair outranks a stored value', ...
        isequal(r.downsampling.batch_sz,700) && ...
        isequal(r.motion_correction.batch_sz,700), '');

    o = base; o.downsampling.batch_sz = 0; o.inter_session_alignment.batch_sz = 250;
    r = CaliAli_parameters(o);
    C{end+1} = chk_true('two different per-module values both survive', ...
        isequal(r.downsampling.batch_sz,0) && ...
        isequal(r.inter_session_alignment.batch_sz,250), '');

    % the empty-seed rule: derivation must still propagate
    r = CaliAli_parameters(base);
    C{end+1} = chk_true('derived values are not undone by the empty seed', ...
        ~isempty(r.cnmf.gSiz) && ~isempty(r.cnmf.ring_radius) && ...
        ~isempty(r.downsampling.BVsize), ...
        sprintf('gSiz=%s ring=%s', mat2str(r.cnmf.gSiz), mat2str(r.cnmf.ring_radius)));

    o = base; o.motion_correction.batch_sz = 250;
    a = CaliAli_parameters(o); b = CaliAli_parameters(a);
    C{end+1} = chk_true('repeated parsing is stable', isequal(a,b), '');

    C{end+1} = chk_true('the deliberate preprocessing override survives', ...
        isequal(a.motion_correction.preprocessing.detrend, false) && ...
        ~isequal(a.preprocessing.detrend, false), '');
catch ME
    C{end+1} = chk_fail('parameter precedence', ME.message);
end
end

function C = unit_batch_modes()
%% batch_sz names what it wants instead of encoding it in the number 0.
%
% 0 used to mean two different things depending on who read it: "the whole file
% at once" before the sessions are concatenated, "one batch per session" after.
% The named modes say which. 0 is still accepted, and must still resolve to the
% reading its own module has always used, or every saved option struct changes
% behaviour silently.
C = {};
try
    C{end+1} = chk_true('auto is a mode', ...
        strcmp(resolve_batch_mode('auto'),'auto'), '');
    C{end+1} = chk_true('all_frames is a mode', ...
        strcmp(resolve_batch_mode('all_frames'),'all_frames'), '');
    C{end+1} = chk_true('per_session is a mode', ...
        strcmp(resolve_batch_mode('per_session'),'per_session'), '');
    [m,n] = resolve_batch_mode(250);
    C{end+1} = chk_true('a number is a fixed batch', ...
        strcmp(m,'fixed') && n==250, sprintf('%s %d', m, n));

    C{end+1} = chk_true('legacy 0 means all frames at file level', ...
        strcmp(resolve_batch_mode(0),'all_frames'), '');
    C{end+1} = chk_true('legacy 0 means per session after concatenation', ...
        strcmp(resolve_batch_mode(0,'per_session'),'per_session'), '');

    C{end+1} = chk_num('all_frames resolves to the no-split sentinel', ...
        compute_auto_batch_size('all_frames',[],[64 64]), 0, 0);
    C{end+1} = chk_num('per_session resolves to the no-split sentinel', ...
        compute_auto_batch_size('per_session',[],[64 64]), 0, 0);
    C{end+1} = chk_num('a number passes through untouched', ...
        compute_auto_batch_size(250,[],[64 64]), 250, 0);
catch ME
    C{end+1} = chk_fail('batch mode vocabulary', ME.message);
end

try
    resolve_batch_mode('per-session');
    C{end+1} = chk_fail('a misspelled mode is rejected', 'no error raised');
catch
    C{end+1} = chk_true('a misspelled mode is rejected', true, '');
end

try
    o = CaliAli_parameters('batch_sz','per_session');
    C{end+1} = chk_true('a mode reaches every module', ...
        strcmp(o.downsampling.batch_sz,'per_session') && ...
        strcmp(o.motion_correction.batch_sz,'per_session') && ...
        strcmp(o.inter_session_alignment.batch_sz,'per_session'), '');

    o = CaliAli_parameters();
    o.inter_session_alignment.batch_sz = 'per_session';
    r = CaliAli_parameters(o);
    C{end+1} = chk_true('a mode set on one module stays there', ...
        strcmp(r.inter_session_alignment.batch_sz,'per_session') && ...
        ~strcmp(r.motion_correction.batch_sz,'per_session'), '');
    C{end+1} = chk_true('a mode survives re-parsing', ...
        isequal(CaliAli_parameters(r), r), '');

    C{end+1} = chk_true('case is normalised', ...
        strcmp(CaliAli_parameters('batch_sz','PER_SESSION').downsampling.batch_sz, ...
        'per_session'), '');
catch ME
    C{end+1} = chk_fail('batch mode through CaliAli_parameters', ME.message);
end

try
    CaliAli_parameters('batch_sz','per-session');
    C{end+1} = chk_fail('a misspelled mode is rejected at parse', 'no error raised');
catch
    C{end+1} = chk_true('a misspelled mode is rejected at parse', true, '');
end
end

function C = unit_translation_bound()
%% The border ignored while estimating the session shift must scale.
%
% It was a flat 20 pixels whatever the recording, which is 11% of a 180-row
% frame and 26% of the same frame after spatial_ds=2 -- the smaller the frame,
% the larger the share thrown away. The replacement is a share of the frame
% capped at the old value, so it never trims MORE than before and only relaxes
% the axes that were being over-trimmed.
C = {};
try
    [b1,b2] = translation_bound_default([512 512]);
    C{end+1} = chk_true('a large frame keeps the historical trim', ...
        b1==20 && b2==20, sprintf('%d / %d', b1, b2));

    [b1,b2] = translation_bound_default([78 118]);
    C{end+1} = chk_true('a small frame is trimmed less', ...
        b1 < 20 && b2 <= 20, sprintf('%d / %d', b1, b2));

    over = false; grew = false;
    for d = [8 16 32 64 90 128 180 256 512 1024]
        [a,~] = translation_bound_default([d d]);
        if a > 20, over = true; end            % never more than before
        if a > 0.42*d, grew = true; end        % never most of the axis
        if mod(a,2) ~= 0, grew = true; end     % must split evenly per side
    end
    C{end+1} = chk_true('never trims more than the flat 20 px it replaces', ~over, '');
    C{end+1} = chk_true('never eats the frame, always even', ~grew, '');

    [a,~] = translation_bound_default([100 100]);
    [b,~] = translation_bound_default([200 200]);
    C{end+1} = chk_true('monotone in frame size', a <= b, sprintf('%d <= %d', a, b));
catch ME
    C{end+1} = chk_fail('translation bound', ME.message);
end
end

function C = unit_w_overlap()
%% Padding follows the patch size instead of being a fixed 32 pixels.
C = {};
try
    d = CNMFE_parameters(struct('gSig',3));
    C{end+1} = chk_num('default patch padding unchanged', d.pars_envs.w_overlap, 32, 0);
    s = CNMFE_parameters(struct('gSig',3,'pars_envs',struct('patch_dims',[32 32])));
    C{end+1} = chk_num('padding follows a 32x32 patch', s.pars_envs.w_overlap, 16, 0);
    e = CNMFE_parameters(struct('gSig',3,'pars_envs',struct('patch_dims',[32 32],'w_overlap',8)));
    C{end+1} = chk_num('explicit padding is still honoured', e.pars_envs.w_overlap, 8, 0);
catch ME
    C{end+1} = chk_fail('w_overlap', ME.message);
end
end

function C = unit_mat_data_cache()
%% The patched data is cached outside the base workspace.
C = {};
try
    mat_data_cache('clear');
    C{end+1} = chk_true('cache starts empty', ~mat_data_cache('has','k'), '');
    mat_data_cache('set','k',struct('a',1));
    C{end+1} = chk_true('cache stores', mat_data_cache('has','k'), '');
    g = mat_data_cache('get','k');
    C{end+1} = chk_true('cache round trip', isstruct(g) && g.a==1, '');
    before = evalin('base','who');
    mat_data_cache('set','k2',rand(5));
    after = evalin('base','who');
    C{end+1} = chk_true('cache creates nothing in base', ...
        isequal(sort(before), sort(after)), '');
    mat_data_cache('clear');
    C{end+1} = chk_true('cache clears', ~mat_data_cache('has','k'), '');
catch ME
    C{end+1} = chk_fail('mat_data_cache', ME.message);
end
end


%% ========================================================================
%  Simulation
%  ========================================================================
function sim = make_simulation(dir_, args, nonrigid_std)
%% NONRIGID_STD is the within-session deformation amplitude, in pixels. Zero --
% the default, and what every scenario but the non-rigid pair uses -- leaves the
% within-session motion purely translational, as it has always been.
if nargin < 3 || isempty(nonrigid_std), nonrigid_std = 0; end
%% One recording, default neuron settings, with motion.
%
% session_motion_std must be non-zero: it is what makes translation happen, and
% therefore what the valid-region mask is for. Note that setting it to zero also
% makes the simulator append _mc to the filenames.
%
% A DIFFERENT AMPLITUDE PER SESSION. Motion correction crops each session to the
% region that stayed valid through its own shaking, so the amount of shaking
% decides how much is cropped. Give every session the same amplitude and they
% come out within a pixel or two of each other, which never tests the case where
% sessions reach alignment at genuinely different sizes and off centre -- the
% case scenario E exists for. These three span a factor of four.
if ~isfolder(dir_), mkdir(dir_); end
here = pwd; c = onCleanup(@() cd(here)); %#ok<NASGU>
motion = repmat([2 5 8], 1, ceil(args.sessions/3));
files = Simulate_Ca_video('outpath', dir_, 'ses', args.sessions, 'F', args.frames, ...
    'seed', 20260915, 'save_GT', false, 'save_mat', true, 'save_avi', 1, ...
    'session_motion_std', motion(1:args.sessions), ...
    'session_nonrigid_std', nonrigid_std, 'translation_misalignment', 1);
cd(here);
sim = load_simulation(dir_);
sim.files = files;
end

function sim = load_simulation(dir_)
mf = dir(fullfile(dir_,'*_meta.mat'));
if isempty(mf), error('CaliAli:benchmark:noMeta','No *_meta.mat in %s', dir_); end
[~,i] = max([mf.datenum]);
sim.meta = fullfile(mf(i).folder, mf(i).name);
sim.dir = dir_;
av = dir(fullfile(dir_,'*_ses*.avi'));
sim.files = arrayfun(@(f) fullfile(f.folder,f.name), av, 'UniformOutput', false);
end

function files = copy_inputs(src, dst)
%% Each scenario gets its own copy, so nothing is shared or reused.
files = cell(size(src));
for i = 1:numel(src)
    [~,n,e] = fileparts(src{i});
    files{i} = fullfile(dst,[n e]);
    copyfile(src{i}, files{i});
end
files = files(:)';
end

function files = blank_one_frame(files)
%% Make frame 10 of the first video a dropped frame, as a camera would.
v = VideoReader(files{1}); %#ok<TNMLP>
F = read(v, [1 Inf]);
F(:,:,:,10) = 0;
w = VideoWriter(files{1}, 'Uncompressed AVI'); w.FrameRate = v.FrameRate;
open(w); for k = 1:size(F,4), writeVideo(w, F(:,:,:,k)); end; close(w);
end


%% ========================================================================
%  A/B against main
%  ========================================================================
function out = run_against_main(args, sim)
%% Run the same scenarios against a worktree of main.
% A worktree rather than a branch switch: the working tree is not disturbed, and
% the two arms can run one after the other unattended.
out = struct('ok',false,'error','','dir','','results',[]);
wt = fullfile(args.out_dir,'worktree_main');
try
    [st,msg] = system(sprintf('cd %s && git worktree add -f %s main 2>&1', ...
        escape(args.repo), escape(wt)));
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
    out.error = format_error(ME);
    fprintf(2,'A/B against main failed: %s\n', ME.message);
end
end


function C = check_size_reconciliation(ds, aligned, opt)
%% Sessions of different size must be reconciled, not silently truncated.
%
% Motion correction run per session outside CaliAli crops each one differently,
% so the sessions arrive at different sizes. match_video_size crops them all to
% the region they share, and alignment then crops again to the region that is
% still valid after the sessions have been shifted onto each other.
%
% The earlier version of this check asserted that the aligned frame is at least
% as large as the smallest input. That can never hold, and the assertion was
% wrong rather than the pipeline: cropping to the valid region is what alignment
% is for. Scenario A loses 7 rows and 9 columns the same way and was only silent
% about it because it does not enable this check.
%
% What is worth asserting is that the loss is ACCOUNTED FOR: no frame is
% dropped, the result is no larger than the region the sessions share, and it is
% smaller than that region by no more than the shifts can explain.
C = {};
try
    sizes = zeros(numel(ds),3);
    for i = 1:numel(ds)
        sizes(i,:) = get_data_dimension(ds{i});
    end
    C{end+1} = chk_true('sessions really do differ in size', ...
        numel(unique(sizes(:,1))) > 1 || numel(unique(sizes(:,2))) > 1, ...
        mat2str(sizes(:,1:2)));

    d = get_data_dimension(aligned);
    C{end+1} = chk_num('no frame lost reconciling the sizes', ...
        d(3), sum(sizes(:,3)), 0);

    % The shared region: every session centred on the others, so each axis is
    % the smallest of the inputs.
    shared = [min(sizes(:,1)), min(sizes(:,2))];
    C{end+1} = chk_true('aligned frame does not exceed the shared region', ...
        d(1) <= shared(1) && d(2) <= shared(2), ...
        sprintf('%dx%d vs shared %dx%d', d(1), d(2), shared(1), shared(2)));

    % What the alignment itself may cost. Each of the two registration passes,
    % translation and non-rigid, can take a row and a column off each side, and
    % a shift of s pixels costs ceil(s) more. Anything beyond that is a border
    % being thrown away for no stated reason, which is the thing worth catching.
    T = getfield_or(opt.inter_session_alignment, 'T', zeros(1,2));
    if isempty(T), T = zeros(1,2); end
    budget = 2*(2 + ceil(max(abs(T(:)))));
    lost = shared - d(1:2);
    C{end+1} = chk_true('border loss is no more than the shifts explain', ...
        all(lost <= budget) && all(lost >= 0), ...
        sprintf('lost %dx%d, budget %d (max |shift| %.2f)', ...
        lost(1), lost(2), budget, max(abs(T(:)))));
catch ME
    C{end+1} = chk_fail('size reconciliation', ME.message);
end
end

function C = check_missing_options(files, dir_)
%% A file with no CaliAli_options must complain, not proceed on defaults.
%
% Silently substituting defaults is the worst outcome: the run completes and
% every number downstream is computed under settings the user never chose. The
% assertion is therefore about NOISE, not success -- an error or a warning, but
% not silence.
C = {};
try
    opt = CaliAli_demo_parameters();
    opt.downsampling.input_files = files;
    opt.downsampling.batch_sz = 0;
    opt = CaliAli_downsample(opt);
    ds = opt.downsampling.output_files;

    % strip the options out of the first file, as an older or hand-made file
    stripped = fullfile(dir_, 'no_options_ds.mat');
    copyfile(ds{1}, stripped);
    m = matfile(stripped, 'Writable', true);
    vars = whos(m);
    C{end+1} = chk_true('the file had CaliAli_options to begin with', ...
        any(strcmp({vars.name},'CaliAli_options')), '');
    warning('off','all'); lastwarn('');
    complained = false; msg = '';
    try
        o2 = CaliAli_parameters();
        o2.inter_session_alignment.input_files = {stripped};
        evalc('CaliAli_align_sessions(o2);');
        [w, ~] = lastwarn;
        complained = ~isempty(w); msg = w;
    catch ME2
        complained = true; msg = ME2.message;
    end
    warning('on','all');
    C{end+1} = chk_true('a file without CaliAli_options is reported', complained, ...
        tern(complained, first_line(msg), 'it ran silently on defaults'));
catch ME
    C{end+1} = chk_fail('missing options', ME.message);
end
end

function C = check_propagation(opt, ds, aligned, sim)
%% A setting must reach the stage that uses it, and be recorded in its output.
C = {};
try
    % spatial downsampling actually applied
    src = VideoReader(sim.files{1}); %#ok<TNMLP>
    want = [floor(src.Height/opt.downsampling.spatial_ds), ...
            floor(src.Width /opt.downsampling.spatial_ds)];
    got = get_data_dimension(ds{1});
    C{end+1} = chk_true('spatial_ds was applied', ...
        abs(got(1)-want(1)) <= 1 && abs(got(2)-want(2)) <= 1, ...
        sprintf('%dx%d, expected about %dx%d', got(1), got(2), want(1), want(2)));

    % output_class actually applied
    C{end+1} = chk('output_class was applied', mat_class(ds{1}), ...
        lower(char(opt.downsampling.output_class)));

    % the settings are recorded in what the stage wrote, not just held in memory
    stored = CaliAli_load(ds{1}, 'CaliAli_options');
    C{end+1} = chk_num('spatial_ds recorded in the _ds file', ...
        stored.downsampling.spatial_ds, opt.downsampling.spatial_ds, 0);
    stored_al = CaliAli_load(aligned, 'CaliAli_options');
    C{end+1} = chk_num('spatial_ds survives to the aligned file', ...
        stored_al.downsampling.spatial_ds, opt.downsampling.spatial_ds, 0);

    % a setting the user never touched must not have been invented
    C{end+1} = chk_num('temporal_ds left at its default', ...
        stored.downsampling.temporal_ds, 1, 0);
catch ME
    C{end+1} = chk_fail('settings propagation', ME.message);
end
end

function dark = poke_dark_pixels(files)
%% Kill a few sensor pixels in the RAW recording, before anything touches it.
%
% Raw, because that is where a dead pixel actually is. Poking the downsampled
% file instead would be poking something the scan has already passed, and would
% also be a defect the pipeline had no chance to see at full resolution -- which
% is the only place a dead pixel is still one pixel.
%
% Well inside the frame: an edge zero IS what a translation border looks like,
% and that is a different defect with a different repair.
dark = struct('file', {}, 'rc', {});
for i = 1:numel(files)
    v = VideoReader(files{i}); %#ok<TNMLP>
    F = read(v, [1 Inf]);
    rc = [round(size(F,1)*[0.3 0.5 0.7])', round(size(F,2)*[0.4 0.5 0.6])'];
    for k = 1:size(rc,1)
        F(rc(k,1), rc(k,2), :, :) = 0;
    end
    w = VideoWriter(files{i}, 'Uncompressed AVI'); w.FrameRate = v.FrameRate;
    open(w); for t = 1:size(F,4), writeVideo(w, F(:,:,:,t)); end; close(w);
    dark(end+1) = struct('file', files{i}, 'rc', rc); %#ok<AGROW>
end
end


function C = check_dark_pixels(ds, ~, dark)
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
    C{end+1} = chk_true('the dead pixels were written into the raw video', ...
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
    C{end+1} = chk_true('downsampling recorded the repair', ...
        all(found > 0), sprintf('dead pixels found per session: %s', mat2str(found)));

    % EVERY poked pixel must be found. Missing one is the failure that matters:
    % a dead pixel left in place does not move with the tissue, and motion
    % correction registers against whatever does not move.
    C{end+1} = chk_true('every dead pixel was found', all_hit, ...
        sprintf('%d poked per session, found %s', n_poked, mat2str(found)));

    % Extras are not required to be zero. A real recording contains pixels that
    % genuinely are anomalous, and interpolating a few isolated ones from their
    % neighbours is harmless -- where missing a real defect is not. So the bias
    % is deliberately permissive, and what is asserted is that it stays small.
    C{end+1} = chk_true('it does not flag the whole sensor', ...
        max(extras) <= max(10, 0.001*frame_px), ...
        sprintf('extras per session %s, of %d pixels', mat2str(extras), frame_px));
catch ME
    C{end+1} = chk_fail('dead pixel', ME.message);
end
end


function mc = correct_each_session_alone(ds, opt)
%% Motion-correct every session on its own, then erase the record of how.
%
% Correcting them one at a time is what makes this different from the normal
% path: each session is cropped to ITS OWN valid region, so the crop is a
% different size and sits at a different place in the original frame. Stripping
% motion_correction afterwards removes the only thing that says where -- the
% Mask, which CaliAli keeps at the pre-crop size with the kept rectangle marked.
% What reaches alignment is then exactly what an external tool hands over:
% corrected sessions of different sizes, off centre from each other, with nothing
% recorded about the padding.
mc = cell(1, numel(ds));
for i = 1:numel(ds)
    o = opt;
    o.motion_correction.input_files  = ds(i);
    o.motion_correction.output_files = [];
    o = CaliAli_motion_correction(o);
    mc{i} = o.motion_correction.output_files{1};
end
forget_motion_record(mc);
end


function forget_motion_record(files)
%% Reset motion_correction to its defaults, so no trace of the crop survives.
% Not the whole CaliAli_options: a file with none of that is scenario K, and the
% requirement there is that the pipeline REFUSES it. The file here is valid, it
% simply has no history.
fresh = CaliAli_parameters();
for i = 1:numel(files)
    o = CaliAli_load(files{i}, 'CaliAli_options');
    o.motion_correction = fresh.motion_correction;
    CaliAli_save(files{i}, 'CaliAli_options', o);
end
end

function t = first_line(s)
s = char(s); nl = find(s==newline, 1);
if isempty(nl), t = s; else, t = s(1:nl-1); end
if numel(t) > 90, t = [t(1:87) '...']; end
end


%% ========================================================================
%  Metrics and the comparison between arms
%  ========================================================================
function m = collect_metrics(opt, score, timing)
%% Every number worth putting side by side with the other arm.
%
% These changes are procedural, so the expectation is EQUALITY, not improvement.
% A difference in any of these is the finding: it means a change that was only
% supposed to move files around also moved a number.
m = struct();
isa_ = opt.inter_session_alignment;

m.BV_score = getfield_or(isa_, 'BV_score', NaN);
try
    t = isa_.alignment_metrics;
    v = t.("Mean Corr. Score"); if iscell(v), v = cell2mat(v); end
    m.corr_before  = v(1);
    m.corr_after   = v(end);
    c = t.("Crispness"); if iscell(c), c = cell2mat(c); end
    m.crispness_before = c(1);
    m.crispness_after  = c(end);
catch
    m.corr_before = NaN; m.corr_after = NaN;
    m.crispness_before = NaN; m.crispness_after = NaN;
end
m.n_sessions = numel(getfield_or(isa_,'F',[]));
m.total_frames = sum(getfield_or(isa_,'F',NaN));

if ~isempty(score)
    m.auc_f1        = score.auc_f1;
    m.auc_precision = score.auc_precision;
    m.auc_recall    = score.auc_recall;
    m.n_extracted   = score.n_extracted;
else
    m.auc_f1 = NaN; m.auc_precision = NaN; m.auc_recall = NaN; m.n_extracted = NaN;
end

% Timings are compared but never asserted: they vary with the machine and its
% load, so a tolerance would be either meaningless or permanently red. They are
% reported as a ratio so a stage that changed materially is still visible.
if nargin > 2 && ~isempty(timing)
    m.sec_downsample        = timing.downsample;
    m.sec_motion_correction = timing.motion_correction;
    m.sec_alignment         = timing.alignment;
    m.sec_extraction        = timing.extraction;
    m.sec_total             = timing.total;
end
end

function cmp = compare_arms(this_arm, other_arm)
%% Join the two arms by scenario and report every metric that moved.
%
% TOLERANCES. Anything that is a count must match exactly -- a differing frame
% or component count is never rounding. The continuous metrics get a small
% tolerance for numerical noise, but not enough to hide a real change.
tol = struct('BV_score',0.05,'corr_before',1e-3,'corr_after',1e-3, ...
    'crispness_before',1e-3,'crispness_after',1e-3, ...
    'auc_f1',0.01,'auc_precision',0.01,'auc_recall',0.01, ...
    'n_sessions',0,'total_frames',0,'n_extracted',0);

cmp = struct('id',{},'metric',{},'this',{},'other',{},'delta',{},'within_tol',{});
for i = 1:numel(this_arm)
    a = this_arm(i);
    j = find(strcmp({other_arm.id}, a.id), 1);
    if isempty(j), continue; end
    b = other_arm(j);
    if isempty(fieldnames(a.metrics)) || isempty(fieldnames(b.metrics)), continue; end
    names = intersect(fieldnames(a.metrics), fieldnames(b.metrics));
    for k = 1:numel(names)
        n = names{k};
        va = a.metrics.(n); vb = b.metrics.(n);
        if ~isnumeric(va) || ~isnumeric(vb) || ~isscalar(va) || ~isscalar(vb), continue; end
        d = double(va) - double(vb);
        if startsWith(n, 'sec_')
            % informational: machine load decides these, not the code
            cmp(end+1) = struct('id',a.id,'metric',n,'this',va,'other',vb, ...
                'delta',d,'within_tol',true); %#ok<AGROW>
            continue
        end
        t = getfield_or(tol, n, 0);
        ok = (isnan(va) && isnan(vb)) || abs(d) <= t;
        cmp(end+1) = struct('id',a.id,'metric',n,'this',va,'other',vb, ...
            'delta',d,'within_tol',ok); %#ok<AGROW>
    end
end
end

function d = compare_checks(this_arm, other_arm)
%% Which checks changed state between the two arms.
%
% This is the point of the exercise. A check that FAILS on main and PASSES here
% is a fix, confirmed on a real run rather than asserted in a commit message. A
% check that passes on main and fails here is a regression, and is the only
% thing in this report that should worry anyone.
d = struct('id',{},'name',{},'this',{},'other',{},'verdict',{});
for i = 1:numel(this_arm)
    a = this_arm(i);
    j = find(strcmp({other_arm.id}, a.id), 1);
    if isempty(j) || isempty(a.checks), continue; end
    b = other_arm(j);
    if isempty(b.checks), continue; end
    for k = 1:numel(a.checks)
        n = a.checks(k).name;
        m = find(strcmp({b.checks.name}, n), 1);
        if isempty(m), continue; end
        pa = a.checks(k).pass; pb = b.checks(m).pass;
        if pa == pb, continue; end
        d(end+1) = struct('id',a.id,'name',n,'this',pa,'other',pb, ...
            'verdict',tern(pa,'FIXED','REGRESSED')); %#ok<AGROW>
    end
end
end

function C = check_batch_invariance(scenarios)
%% Chunking must not change the numbers, only the memory used to get them.
% A, B and C differ only in batch size, so their downsampled outputs must be
% bit-identical. If they are not, chunking is losing or duplicating frames.
C = {};
ids = {'A','B','C'};
if isempty(scenarios)
    C{end+1} = chk_fail('batch invariance', 'no scenario completed');
    return
end
have = cellfun(@(x) any(strcmp({scenarios.id},x) & [scenarios.ok]), ids);
if sum(have) < 2
    C{end+1} = chk_fail('batch invariance', 'fewer than two of A, B, C completed');
    return
end
ids = ids(have);
try
    ref = [];
    for i = 1:numel(ids)
        r = scenarios(strcmp({scenarios.id}, ids{i}));
        m = matfile(r.ds_files{1});
        Y = m.Y;
        if isempty(ref)
            ref = Y; ref_id = ids{i};
        else
            C{end+1} = chk_true(sprintf('batch invariance: %s matches %s', ids{i}, ref_id), ...
                isequal(Y, ref), sprintf('%s vs %s', mat2str(size(Y)), mat2str(size(ref)))); %#ok<AGROW>
        end
    end
catch ME
    C{end+1} = chk_fail('batch invariance', ME.message);
end
end

function C = check_dark_pixel_costs_nothing(scenarios)
%% M is A with a few genuinely dark pixels. The frames must come out identical.
% If M's aligned frame is smaller, a zero is still being read as a missing pixel
% somewhere, and everything between it and the frame edge went with it.
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
    C{end+1} = chk_true('a dark pixel costs no frame area', ...
        isequal(da(1:2), dm(1:2)), ...
        sprintf('A %s vs M %s', mat2str(da(1:2)), mat2str(dm(1:2))));
catch ME
    C{end+1} = chk_fail('dark pixel cost', ME.message);
end
end


function C = check_non_rigid_does_no_harm(scenarios)
%% Switching non-rigid correction on must not cost anything when there is
%% nothing for it to correct.
%
% A and F are the same recording and the same options apart from do_non_rigid,
% and that recording's within-session motion is pure translation. So a correctly
% parameterised patch correction has nothing to find, should estimate almost
% nothing, and should land where rigid alone lands. Any real loss here is the
% patches warping the frame on no evidence -- which is a parameter problem, most
% often an overlap or a max_dev that did not scale with the patch size.
%
% The tolerances are deliberately loose. This is not asking the correction to be
% good, only to be harmless: an extra resampling pass over every pixel costs a
% little blur whatever the field is, and that much is unavoidable.
C = {};
try
    have = @(x) any(strcmp({scenarios.id},x) & [scenarios.ok]);
    if ~(have('A') && have('F')), return; end
    a = scenarios(strcmp({scenarios.id},'A'));
    f = scenarios(strcmp({scenarios.id},'F'));

    C{end+1} = chk_true('non-rigid does not blur a recording that does not deform', ...
        f.metrics.crispness_before >= 0.9*a.metrics.crispness_before, ...
        sprintf('crispness %.3f on, %.3f off', ...
        f.metrics.crispness_before, a.metrics.crispness_before));

    C{end+1} = chk_true('and does not cost extraction quality', ...
        f.metrics.auc_f1 >= a.metrics.auc_f1 - 0.05, ...
        sprintf('F1 area %.3f on, %.3f off', f.metrics.auc_f1, a.metrics.auc_f1));
catch ME
    C{end+1} = chk_fail('non-rigid no-harm', ME.message);
end
end


function C = check_non_rigid_helps(scenarios)
%% On a recording that deforms, correcting the deformation must be worth doing.
%
% F1 and F2 are the same simulation and the same options apart from
% do_non_rigid, so any difference between them is the non-rigid pass and nothing
% else. This is the check the old scenario F could never make: it ran on a
% recording whose within-session motion was pure translation, where the non-rigid
% pass has nothing to find and can only lose.
%
% Crispness is the measure, not correlation between sessions. Deformation is a
% WITHIN-session defect: it blurs each session's own projections, and crispness
% is what reads that directly. A correction that undoes it sharpens the
% projections it is handed.
C = {};
try
    have = @(x) any(strcmp({scenarios.id},x) & [scenarios.ok]);
    if ~(have('F1') && have('F2'))
        return   % not both run; nothing to compare, and not a failure
    end
    a = scenarios(strcmp({scenarios.id},'F1'));
    b = scenarios(strcmp({scenarios.id},'F2'));

    C{end+1} = chk_true('non-rigid correction sharpens a deforming recording', ...
        b.metrics.crispness_before >= a.metrics.crispness_before, ...
        sprintf('crispness %.3f with, %.3f without', ...
        b.metrics.crispness_before, a.metrics.crispness_before));

    C{end+1} = chk_true('and does not cost extraction quality', ...
        b.metrics.auc_f1 >= a.metrics.auc_f1 - 0.02, ...
        sprintf('F1 area %.3f with, %.3f without', b.metrics.auc_f1, a.metrics.auc_f1));
catch ME
    C{end+1} = chk_fail('non-rigid comparison', ME.message);
end
end


function rec = normalize_rec(rec, fields)
%% Give every record the same fields, in the same order.
for i = 1:numel(fields)
    if ~isfield(rec, fields{i})
        rec.(fields{i}) = [];
    end
end
extra = setdiff(fieldnames(rec), fields);
if ~isempty(extra), rec = rmfield(rec, extra); end
rec = orderfields(rec, fields);
end

function v = getfield_or(s, name, dflt)
v = dflt;
try
    if isfield(s, name) && ~isempty(s.(name)), v = s.(name); end
catch
end
end


%% ========================================================================
%  Plumbing
%  ========================================================================
function setup_paths(repo, simulator, metrics)
%% Put the repo under test on the path, and nothing that could shadow it.
%
% This used to add genpath(fileparts(metrics)), the whole scratch tree the
% benchmark writes into. The worktree of main that the A/B comparison checks out
% lives in that tree, so on the SECOND run every function came from main
% instead of from the branch under test -- addpath prepends, so the later
% addpath wins. The unit checks failed with main's error messages while
% reporting on this branch. Add the two helper folders by name instead.
restoredefaultpath;
addpath(genpath(repo));
if isfolder(simulator), addpath(genpath(simulator)); end
if isfolder(metrics),   addpath(metrics); end
harness = fullfile(fileparts(metrics), 'harness');
if isfolder(harness),   addpath(harness); end
% The repo under test must win over anything added above it.
addpath(genpath(repo));
warning('off','MATLAB:rmpath:DirNotFound');
end

function opt = apply_overrides(opt, pairs)
for i = 1:2:numel(pairs)
    parts = strsplit(pairs{i}, '.');
    opt.(parts{1}).(parts{2}) = pairs{i+1};
end
end

function c = column_cell(x)
if ~iscell(x), x = {x}; end
c = x(:);
end

function cls = mat_class(f)
cls = '';
try
    if iscell(f), f = f{1}; end
    w = whos(matfile(char(f)),'Y');
    if ~isempty(w), cls = w.class; end
catch
end
end

function F = read_frame(f, idx)
if iscell(f), f = f{1}; end
m = matfile(char(f));
F = m.Y(:,:,idx);
end

function tf = has(list, name)
tf = any(strcmp(list, name));
end

function s = escape(p)
s = ['"' char(p) '"'];
end

function o = tern(c,a,b)
if c, o = a; else, o = b; end
end

function s = format_error(ME)
s = ME.message;
for i = 1:numel(ME.stack)
    s = sprintf('%s\n    at %s line %d', s, ME.stack(i).name, ME.stack(i).line);
end
end

%% ---- check constructors -------------------------------------------------
function c = chk(name, got, want)
c = struct('name',name,'pass',isequal(got,want), ...
    'detail',sprintf('got %s, want %s', tostr(got), tostr(want)));
end
function c = chk_num(name, got, want, tol)
c = struct('name',name,'pass',abs(double(got)-double(want)) <= tol, ...
    'detail',sprintf('got %g, want %g (tol %g)', got, want, tol));
end
function c = chk_true(name, cond, detail)
c = struct('name',name,'pass',logical(cond),'detail',char(detail));
end
function c = chk_fail(name, detail)
c = struct('name',name,'pass',false,'detail',char(detail));
end
function s = tostr(v)
if ischar(v), s = v; elseif isnumeric(v) || islogical(v), s = mat2str(v); else, s = class(v); end
end

%% ---- reporting ----------------------------------------------------------
function banner(t)
fprintf('\n%s\n%s\n%s\n', repmat('=',1,72), t, repmat('=',1,72));
end

function print_checks(C)
for i = 1:numel(C)
    if C(i).pass
        fprintf('  [pass] %-52s %s\n', C(i).name, C(i).detail);
    else
        fprintf(2,'  [FAIL] %-52s %s\n', C(i).name, C(i).detail);
    end
end
end

function print_report(r)
banner('Summary');
np = @(C) sum([C.pass]);
fprintf('unit checks      : %d of %d passed\n', np(r.unit), numel(r.unit));
fprintf('\n%-6s %-46s %-9s %6s %s\n','id','scenario','checks','sec','status');
fprintf('%s\n', repmat('-',1,88));
for i = 1:numel(r.scenarios)
    s = r.scenarios(i);
    if isempty(s.checks), cc = '-'; else, cc = sprintf('%d/%d', np(s.checks), numel(s.checks)); end
    fprintf('%-6s %-46s %-9s %6.0f %s\n', s.id, s.name, cc, s.seconds, ...
        tern(s.ok,'ok','FAILED'));
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
    banner('Checks that changed against main');
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
    banner('This branch against main');
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
            c(i).this, c(i).other, c(i).delta, tern(c(i).within_tol,'','<-- MOVED'));
    end
    fprintf('\n%d of %d metrics differ beyond tolerance.\n', sum(moved), numel(c));
elseif isfield(r,'main') && ~r.main.ok
    fprintf(2,'\nA/B against main did not run: %s\n', r.main.error);
end
end
