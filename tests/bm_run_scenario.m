function rec = bm_run_scenario(s, sim, rec, args)
%% One scenario: its own directory, its own copy of the inputs, its own options.
% A fresh directory per scenario is not tidiness. detrend_batch_and_calculate_
% projections reuses a cached _det.mat AND READS THE OPTIONS BACK OUT OF IT, so
% two scenarios sharing a folder silently inherit each other's settings. And
% CaliAli_motion_correction errors when every input is already processed, so a
% second run over the same folder cannot work at all.
if isfolder(rec.dir), rmdir(rec.dir,'s'); end
mkdir(rec.dir);

files = bm_copy_inputs(sim.files, rec.dir);
if strcmp(s.id,'J')
    files = bm_blank_one_frame(files);   % the dropped frame this scenario looks for
end
if strcmp(s.id,'M')
    rec.dark = bm_poke_dark_pixels(files);   % dead pixels in the RAW recording
end

opt = CaliAli_demo_parameters();
opt = bm_apply_overrides(opt, s.opts);
if strcmp(s.id,'H')
    opt.cnmf.pars_envs.patch_dims = [32 32];
    opt.cnmf.pars_envs.w_overlap = [];       % let it be derived
end

C = {};   % checks accumulate here

if strcmp(s.id,'K')
    kc = bm_check_missing_options(files, rec.dir);
    rec.checks = [kc{:}];
    rec.metrics = struct();
    bm_print_checks(rec.checks);
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
    mc = bm_correct_each_session_alone(ds, opt);
else
    mc = ds;
end
T.motion_correction = toc(t);
rec.mc_files = mc;

%% 3. alignment
t = tic;
opt.inter_session_alignment.input_files = bm_column_cell(mc);
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
if bm_has(s.checks,'dtype'),       C = [C, bm_check_dtype(opt, ds, mc, aligned)]; end
if bm_has(s.checks,'offset'),      C = [C, bm_check_no_offset(ds, mc, opt)]; end
if bm_has(s.checks,'mask'),        C = [C, bm_check_mask(opt)]; end
if bm_has(s.checks,'bookkeeping'), C = [C, bm_check_bookkeeping(opt, aligned)]; end
if bm_has(s.checks,'alignment'),   C = [C, bm_check_alignment(opt, aligned)]; end
if bm_has(s.checks,'workspace'),   C = [C, bm_check_workspace(sentinel)]; end
if bm_has(s.checks,'patch'),       C = [C, bm_check_patch(opt)]; end
if bm_has(s.checks,'dropped'),     C = [C, bm_check_dropped(rec.dir, 10)]; end
if bm_has(s.checks,'sizes'),       C = [C, bm_check_size_reconciliation(mc, aligned, opt)]; end
if bm_has(s.checks,'darkpixel'), C = [C, bm_check_dark_pixels(ds, aligned, rec.dark)]; end
if bm_has(s.checks,'propagation'), C = [C, bm_check_propagation(opt, ds, aligned, sim)]; end
if bm_has(s.checks,'gt')
    [gt_checks, rec.score] = bm_check_ground_truth(extraction, sim, opt);
    C = [C, gt_checks];
end

% Everything numeric worth comparing against the other arm, in one flat struct.
rec.metrics = bm_collect_metrics(opt, rec.score, rec.timing);

rec.checks = [C{:}];
bm_print_checks(rec.checks);
end


%% ========================================================================
%  Checks that need no ground truth
%  ========================================================================
