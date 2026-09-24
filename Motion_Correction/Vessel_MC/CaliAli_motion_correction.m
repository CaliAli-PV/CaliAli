function CaliAli_options = CaliAli_motion_correction(varargin)
%% CaliAli_motion_correction: Perform rigid and non-rigid motion correction on video files.
%
% This function applies motion correction to a set of input video files. It performs both
% rigid and non-rigid motion correction, interpolates dropped frames, squares borders, and
% saves the corrected video as a .mat file.
%
% Inputs:
%   varargin - Variable input arguments, which are parsed into CaliAli_options.
%              The details of the CaliAli_options structure can be found in
%              CaliAli_demo_parameters().
%
% Outputs:
%   CaliAli_options - Updated structure containing the motion correction parameters.
%   Saved output files - Motion-corrected video files are saved as .mat files with
%                        the suffix "_mc" in the original file directory.
%
% Usage:
%   CaliAli_options = CaliAli_motion_correction();  % Interactive file selection
%   CaliAli_options = CaliAli_motion_correction(CaliAli_options);  % Using predefined options
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Load motion correction parameters
CaliAli_options = CaliAli_parameters(varargin{:});
opt = CaliAli_options.motion_correction;

% Select input files if not specified
if isempty(opt.input_files)
    opt.input_files = uipickfiles('FilterSpec', '*_ds*.mat');
end

% Sensor defects, for a recording that entered the pipeline late. In the standard
% path this already happened at downsampling, on raw frames, and the record kept
% in each file makes this a no-op. A file motion-corrected outside CaliAli, or
% downsampled by an older version, is caught here instead. It must run BEFORE the
% output files are sized, because removing a border changes the frame.
CaliAli_options = CaliAli_repair_defects(opt.input_files, CaliAli_options, 'motion correction');

% Split the inputs into batches, unless batch_sz asks for the whole file at once
[opt.input_files,opt.batch_sz] = create_batch_list(opt.input_files, opt.batch_sz,'_mc');
% create_batch_list returns the RESOLVED frame count. Writing that back over a
% named mode would erase which mode it was: 'all_frames' and 'per_session' both
% resolve to 0 at this stage, and the steps after concatenation still have to
% tell them apart. Keep the mode, store the number only when a number was given.
if ~ischar(CaliAli_options.motion_correction.batch_sz)
    CaliAli_options.motion_correction.batch_sz=opt.batch_sz;
end

% Pre-allocate output files and get processing flags
% One class for both the container and the data written into it; see
% resolve_stage_class. Empty output_class means "keep what we were given".
mc_class = resolve_stage_class(opt, first_input_file(opt.input_files));
[process_flags,out_pre] = pre_allocate_outputs(opt.input_files,'_mc',mc_class);
try
    % Loop through each input file/batch for motion correction
    for k = 1:length(opt.input_files)
        if ~process_flags(k)
            fprintf(1, 'Skipping already processed batch %d\n', k);
            continue;
        end

        % Handle both string (original) and cell array (batch) inputs
        if ischar(opt.input_files{k})
            fullFileName = opt.input_files{k};
            fprintf(1, 'Now reading %s\n', fullFileName);
            intra_sess_tag= false;
        else
            fullFileName = opt.input_files{k}{1};
            fprintf(1, 'Processing batch from %s\n', fullFileName);
            if opt.input_files{k}{3}>1
                intra_sess_tag= true;
            else
                intra_sess_tag= false;
            end
        end

        % The output name comes from pre_allocate_outputs, which computed one
        % for EVERY input whether it needed processing or not. Rebuilding it
        % here was both redundant and subtly different: this line had no
        % `~contains(name, tag)` guard, so a file already carrying _mc got the
        % tag twice, where create_batch_list and pre_allocate_outputs both
        % leave it alone.
        opt.output_file = out_pre{k};


        % Load video data (handles both string and batch inputs)
        Y = CaliAli_load(opt.input_files{k}, 'Y');

        % Start parallel pool if not already running
        if isempty(gcp('nocreate'))
            parpool
        end
        disp('Calculating translation shift...')
        % Perform rigid motion correction
        % VALID is the region translation left holding real data. It is
        % returned explicitly, so nothing downstream has to infer it from the
        % pixel value -- which is what the +1 offset used to make possible.
        if intra_sess_tag
            [Y, ref,template,valid] = Rigid_mc(Y, opt,template);
        else
            [Y, ref,template,valid] = Rigid_mc(Y, opt);
        end

        % Perform non-rigid motion correction if enabled
        if opt.do_non_rigid
            % The warp fills its own borders, so its valid region has to be
            % folded in or those borders would never be cropped away.
            [Y, valid_nr] = Non_rigid_mc(Y, ref, opt);
            valid = valid & valid_nr;
        end

        % Interpolate dropped frames
        Y = interpolate_dropped_frames(Y, valid);

        % Square the borders of the video
        if intra_sess_tag
            Y = apply_mask_square(Y, Mask);
            [Y,m] = square_borders(Y, [], valid & (Mask>0));
            Mask(Mask>0)=m(Mask>0);
        else
            [Y,Mask] = square_borders(Y, [], valid);
        end
        % Cast once, at the write boundary, to the class the file was
        % preallocated in.
        Y = cast(Y, mc_class);
        opt.Mask=Mask;
        % Save motion-corrected video (handles both string and batch inputs)
        CaliAli_options.motion_correction = opt;
        CaliAli_save(opt.input_files{k}(:), Y, CaliAli_options);
    end

    % Store output file names in options structure.
    %
    % From out_pre, not from a list the loop builds as it goes. The loop skips
    % any input whose output already exists, so on a re-run over a finished
    % folder it skips every one, that list is never created, and the line below
    % failed with "Unrecognized function or variable 'out'" -- reported as issue
    % 36. out_pre is filled for every input before the loop starts, so the
    % re-run now returns the same file names it returned the first time.
    CaliAli_options.motion_correction.output_files = unique(out_pre);

    % Crop only what THIS run wrote. The crop is not idempotent: it trims a file
    % to the bounding box of its Mask, and the Mask is deliberately kept at the
    % PRE-crop size because it records where the kept rectangle sat in the
    % original frame. Applied a second time to an already-cropped file, the
    % sizes no longer agree and it fails with "Mask must be [d1 d2]" -- the
    % second half of issue 36, reached only once the first half stopped masking
    % it. An output that was skipped was cropped on the run that created it.
    fresh = unique(out_pre(process_flags));
    for i=1:numel(fresh)
        apply_crop_on_disk(fresh{i});
    end

catch ME
    if exist(out_pre{1}, 'file') == 2
        remove_corrupted_output(out_pre);
    end
    cprintf('*red', 'Motion correction failed: %s\n', ME.message);
    rethrow(ME);
end
end

function f = first_input_file(files)
%% The first readable input, used to inherit a class when none is declared.
f = '';
if isempty(files), return; end
f = files{1};
if iscell(f), f = f{1}; end
end
