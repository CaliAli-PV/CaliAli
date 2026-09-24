function scn = bm_scenarios()
%% bm_scenarios: Declare every scenario the benchmark runs.
%
% A scenario is a set of option overrides plus the checks it enables. Each one
% exists for a CODE PATH, not for a parameter value.
%
% Inputs:
%   None.
%
% Outputs:
%   scn - Structure array, one element per scenario.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

scn = struct('id',{},'name',{},'opts',{},'checks',{},'mc',{},'sim',{});

scn(end+1) = bm_mk('A','baseline, whole recording in one batch', ...
    {'downsampling.batch_sz',0}, ...
    {'dtype','offset','mask','bookkeeping','alignment','workspace','gt'}, true);

scn(end+1) = bm_mk('B','chunked downsampling and intra-session batches', ...
    {'downsampling.batch_sz',250,'motion_correction.batch_sz',250}, ...
    {'dtype','bookkeeping','alignment','gt','batch_invariance'}, true);

scn(end+1) = bm_mk('C','automatic batch size', ...
    {'downsampling.batch_sz','auto'}, ...
    {'dtype','bookkeeping','gt','batch_invariance'}, true);

scn(end+1) = bm_mk('D1','datatype uint8', ...
    {'downsampling.batch_sz',0,'downsampling.output_class','uint8'}, ...
    {'dtype','bookkeeping'}, true);

% Floating point is refused by design: the pipeline clips against integer maxima
% and subtracts integers from the data during extraction. What is checked is that
% it is refused CLEARLY, at the point of setting it, rather than failing later.
scn(end+1) = bm_mk('D2','a floating-point datatype must be refused', ...
    {'downsampling.batch_sz',0}, {'reject_float'}, false);

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
scn(end+1) = bm_mk('E','motion correction done outside CaliAli', ...
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
scn(end+1) = bm_mk('F','non-rigid on a recording that does not deform', ...
    {'downsampling.batch_sz',0,'motion_correction.do_non_rigid',true}, ...
    {'mask','bookkeeping','alignment','gt'}, true);

scn(end+1) = bm_mk('F1','deforming recording, translation only', ...
    {'downsampling.batch_sz',0,'motion_correction.do_non_rigid',false}, ...
    {'mask','bookkeeping','alignment','gt'}, true, 'nonrigid');

scn(end+1) = bm_mk('F2','deforming recording, translation and non-rigid', ...
    {'downsampling.batch_sz',0,'motion_correction.do_non_rigid',true}, ...
    {'mask','bookkeeping','alignment','gt'}, true, 'nonrigid');

% batch_sz is set FLAT here, and the distinction now matters. A value under
% downsampling applies to downsampling alone, which leaves extraction on 'auto'
% and therefore on a single batch. These exist to reach the parfor path in
% update_temporal_CaliAli, which needs more than one frame batch, so the value
% has to be pipeline-wide.
%
% G1 IS THE ONE THAT MATTERS. CaliAli is for one-photon imaging, so the ring
% background is what every real run uses, and until this scenario existed it had
% never been extracted in more than one batch. The other two models are checked
% separately, in G2 and G3, because they were never implemented for batch mode.
scn(end+1) = bm_mk('G1','ring background, multiple batches, parallel', ...
    {'batch_sz',250,'cnmf.background_model','ring', ...
     'cnmf.use_parallel',true}, ...
    {'bookkeeping','gt'}, true);

scn(end+1) = bm_mk('G2','background svd, multiple batches', ...
    {'batch_sz',250,'cnmf.background_model','svd', ...
     'cnmf.use_parallel',true}, ...
    {'bookkeeping','gt'}, true);

scn(end+1) = bm_mk('G3','background nmf, multiple batches', ...
    {'batch_sz',250,'cnmf.background_model','nmf', ...
     'cnmf.use_parallel',true}, ...
    {'bookkeeping','gt'}, true);

scn(end+1) = bm_mk('H','patch geometry 32x32 (w_overlap derived)', ...
    {'downsampling.batch_sz',0}, {'bookkeeping','gt','patch'}, true);

scn(end+1) = bm_mk('I1','fast PNR projections', ...
    {'downsampling.batch_sz',0,'preprocessing.fastPNR',true}, ...
    {'bookkeeping','alignment'}, true);

scn(end+1) = bm_mk('I2','neuron enhancement off', ...
    {'downsampling.batch_sz',0,'preprocessing.neuron_enhance',false}, ...
    {'bookkeeping','alignment'}, true);

scn(end+1) = bm_mk('J','dropped frame is detected and interpolated', ...
    {'downsampling.batch_sz',0}, {'dropped'}, true);

% A file whose CaliAli_options were lost -- hand-edited, produced by an older
% version, or written by something else. The requirement is not that it works,
% it is that it FAILS LOUDLY rather than continuing with silent defaults.
scn(end+1) = bm_mk('K','a file with no CaliAli_options must complain', ...
    {'downsampling.batch_sz',0}, {'missing_options'}, false);

% A dark pixel in the middle of the field of view. Every border in this pipeline
% used to be found by treating the value 0 as "filled by a translation", so a
% pixel that is genuinely 0 was indistinguishable from one that is missing, and
% got cropped away with everything between it and the frame edge. The valid
% region now comes from the transform instead, so this must cost nothing: same
% options as A, same simulation, and the aligned frame must come out the same
% size. Anything smaller means a value is still being read as absence.
scn(end+1) = bm_mk('M','a dark pixel in the field of view costs nothing', ...
    {'downsampling.batch_sz',0}, ...
    {'dtype','bookkeeping','alignment','gt','darkpixel'}, true);

% Settings must reach the stage that uses them, and be recorded in what it
% writes. A parameter that is quietly ignored is indistinguishable from one that
% was never set.
scn(end+1) = bm_mk('L','settings propagate into the files that stages write', ...
    {'downsampling.batch_sz',0,'downsampling.spatial_ds',2, ...
     'downsampling.output_class','uint8'}, {'propagation'}, true);
end
