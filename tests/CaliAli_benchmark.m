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
results.scenarios = struct('id',{},'name',{},'ok',{},'error',{},'checks',{}, ...
    'score',{},'metrics',{},'seconds',{},'dir',{});

for i = 1:numel(scn)
    s = scn(i);
    fprintf('\n--- %s: %s ---\n', s.id, s.name);
    t0 = tic;
    rec = struct('id',s.id,'name',s.name,'ok',false,'error','', ...
        'checks',struct([]),'score',[],'metrics',struct(),'seconds',0, ...
        'dir',fullfile(args.out_dir, ['scn_' s.id]));
    try
        rec = run_scenario(s, results.sim, rec, args);
        rec.ok = true;
    catch ME
        rec.error = format_error(ME);
        fprintf(2, '  FAILED: %s\n', ME.message);
    end
    rec.seconds = toc(t0);
    cd(start_dir);
    results.scenarios(end+1) = rec; %#ok<AGROW>
    fprintf('  %s in %.0f s\n', tern(rec.ok,'completed','FAILED'), rec.seconds);
end

%% ---- checks that span scenarios -----------------------------------------
banner('Cross-scenario checks');
bi = check_batch_invariance(results.scenarios);
results.cross = [bi{:}];
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
scn = struct('id',{},'name',{},'opts',{},'checks',{},'mc',{});

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

% Motion correction run per session outside CaliAli crops each session by its
% own amount, so the sessions arrive at DIFFERENT SIZES. That is the real shape
% of this case, and what alignment has to reconcile -- not merely a skipped
% stage. One session is deliberately made smaller here.
scn(end+1) = mk('E','external motion correction: sessions of different size', ...
    {'downsampling.batch_sz',0}, ...
    {'dtype','bookkeeping','alignment','gt','sizes'}, false);

scn(end+1) = mk('F','non-rigid motion correction', ...
    {'downsampling.batch_sz',0,'motion_correction.do_non_rigid',true}, ...
    {'mask','bookkeeping','alignment'}, true);

scn(end+1) = mk('G1','background nmf, parallel (reaches the parfor fix)', ...
    {'downsampling.batch_sz',0,'cnmf.background_model','nmf', ...
     'cnmf.use_parallel',true,'inter_session_alignment.batch_sz',250}, ...
    {'bookkeeping','gt'}, true);

scn(end+1) = mk('G2','background svd, parallel', ...
    {'downsampling.batch_sz',0,'cnmf.background_model','svd', ...
     'cnmf.use_parallel',true,'inter_session_alignment.batch_sz',250}, ...
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

% Settings must reach the stage that uses them, and be recorded in what it
% writes. A parameter that is quietly ignored is indistinguishable from one that
% was never set.
scn(end+1) = mk('L','settings propagate into the files that stages write', ...
    {'downsampling.batch_sz',0,'downsampling.spatial_ds',2, ...
     'downsampling.output_class','uint8'}, {'propagation'}, true);
end

function s = mk(id,name,opts,checks,mc)
s = struct('id',id,'name',name,'opts',{opts},'checks',{checks},'mc',mc);
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
if strcmp(s.id,'E')
    files = shrink_one_session(files, 12);   % sessions of unequal size
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

%% 2. motion correction, unless the scenario supplies it externally
t = tic;
if s.mc
    opt.motion_correction.input_files = ds;
    opt = CaliAli_motion_correction(opt);
    mc = opt.motion_correction.output_files;
else
    mc = ds;   % straight into alignment; the value-based fallback recovers the mask
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
if has(s.checks,'sizes'),       C = [C, check_size_reconciliation(ds, aligned)]; end
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
function sim = make_simulation(dir_, args)
%% One recording, default neuron settings, with motion.
% session_motion_std must be non-zero: it is what makes translation happen, and
% therefore what the valid-region mask is for. Note that setting it to zero also
% makes the simulator append _mc to the filenames.
if ~isfolder(dir_), mkdir(dir_); end
here = pwd; c = onCleanup(@() cd(here)); %#ok<NASGU>
files = Simulate_Ca_video('outpath', dir_, 'ses', args.sessions, 'F', args.frames, ...
    'seed', 20260915, 'save_GT', false, 'save_mat', true, 'save_avi', 1, ...
    'session_motion_std', 3, 'translation_misalignment', 1);
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


function C = check_size_reconciliation(ds, aligned)
%% Sessions of different size must be reconciled, not silently truncated.
% Motion correction run per session outside CaliAli crops each one differently.
% match_video_size pads them to a common frame; what must NOT happen is frames
% being dropped, or a session being cut to the smallest common area without
% saying so.
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
    C{end+1} = chk_true('aligned frame is at least as large as the smallest input', ...
        d(1) >= min(sizes(:,1)) && d(2) >= min(sizes(:,2)), ...
        sprintf('%dx%d vs min %dx%d', d(1), d(2), min(sizes(:,1)), min(sizes(:,2))));
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

function files = shrink_one_session(files, px)
%% Crop the first session, so the sessions no longer share a frame size.
v = VideoReader(files{1}); %#ok<TNMLP>
F = read(v, [1 Inf]);
F = F(px+1:end-px, px+1:end-px, :, :);
w = VideoWriter(files{1}, 'Uncompressed AVI'); w.FrameRate = v.FrameRate;
open(w); for k = 1:size(F,4), writeVideo(w, F(:,:,:,k)); end; close(w);
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
restoredefaultpath;
addpath(genpath(repo));
if isfolder(simulator), addpath(genpath(simulator)); end
if isfolder(metrics),   addpath(genpath(fileparts(metrics))); end
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
