function CaliAli_options=CaliAli_downsample(CaliAli_options)
%% CaliAli_downsample: Downsample input video files in time and space.
%
% Reads in chunks, so memory use does not grow with recording length, and
% PRESERVES THE SOURCE DATATYPE. The previous implementation of this function
% cast everything to uint8 and added 1, which silently clipped uint16 and
% floating-point recordings: values above 254 all became 255. That version has
% been removed; this one replaces it. Calls to CaliAli_downsample_batch still
% work through a shim, which warns.
%
% Usage:
%   CaliAli_options = CaliAli_downsample();
%   CaliAli_options = CaliAli_downsample(CaliAli_options);
%
% Notes:
%   - batch_sz: number of downsampled frames per batch. Use a numeric value, or
%     one of the named modes: 'auto' to size the batch against the free memory,
%     'all_frames' to take the file in one piece. 'per_session' means the same as
%     'all_frames' here, because one input file is one session at this stage.
%     0 and Inf still work and still mean all frames.

if nargin < 1 || isempty(CaliAli_options)
    CaliAli_options = CaliAli_parameters();
else
    CaliAli_options = CaliAli_parameters(CaliAli_options);
end

opt = CaliAli_options.downsampling;
batch_sz = opt.batch_sz;
if isempty(opt.input_files)
    opt.input_files = uipickfiles('REFilter','\.h5$|\.avi$|\.m4v$|\.mp4$|\.tif$|\.tiff$|\.isxd$');
end

F = nan(1, numel(opt.input_files));

for k = 1:numel(opt.input_files)
    fullFileName = opt.input_files{k};
    fprintf(1, 'Now reading %s\n', fullFileName);

    if isfolder(fullFileName)
        opt = process_folder_batch(fullFileName, opt,CaliAli_options);
        CaliAli_options.downsampling = opt;
        continue
    end

    [filepath, name, ext] = fileparts(fullFileName);
    outFile = fullfile(filepath, [name '_ds.mat']);
    opt.output_files{k} = outFile;

    if isfile(outFile)
        if ~existing_output_needs_redo(outFile)
            warn_file_exists(outFile);
            continue
        end
    end

    reader = build_reader(fullFileName, ext);
    ds_frames = int32(1:opt.temporal_ds:reader.nFrames);
    Fds = numel(ds_frames);

    first_frame = reader.read_range(1, 1);

    % SENSOR DEFECTS, FOUND ON RAW FRAMES, ONCE FOR THE WHOLE RECORDING.
    %
    % This is the only point in the pipeline where a dead pixel is still a single
    % pixel. Two lines below, imresize averages it with its neighbours: at
    % spatial_ds = 2 a dead pixel leaves four output pixels at about three
    % quarters of their true value, which is neither zero nor obviously
    % low-variance, and the damage is already spread. Temporal downsampling does
    % the same to a dropped frame.
    %
    % It matters because these defects do not move with the tissue, and motion
    % correction registers against whatever does not move. Three dead pixels
    % collapsed a session's estimated shifts from a standard deviation of 2.8
    % pixels to 0.4 -- motion correction stopped working, silently.
    %
    % The scan runs once, before the loop, because the masks have to be the same
    % for every chunk: a dead-pixel set decided per batch would put a seam where
    % one batch ends, and a border decided per batch cannot work at all, since
    % the output file is preallocated from these dimensions.
    defects = scan_for_defects(reader, ds_frames, opt);

    % Only the crop matters for sizing the output; the pixel repairs do not
    % change the dimensions and a single frame is no basis for judging a drop.
    fr = first_frame(defects.rows, defects.cols, 1);
    [d1, d2] = size(imresize(double(fr), 1/opt.spatial_ds, 'bilinear'));

    batch_size = resolve_batch_size(batch_sz, [d1, d2], Fds);
    reader = build_reader(fullFileName, ext, struct('batch_size', batch_size));

    % One class for the whole pipeline, from CaliAli_options. Keeping the source
    % class here only moved the cast one stage later: pre_allocate_outputs
    % creates its files in the same class, so a float recording was converted
    % anyway, after having used four times the memory to get there.
    target_class = resolve_output_class(opt);
    warn_if_cast_destroys(first_frame, target_class, fullFileName);
    % Preallocate output dataset to full size for consistent appends
    m = matfile(outFile, 'Writable', true);
    m.Y = zeros(d1, d2, Fds, target_class);
    clear m

    for startIdx = 1:batch_size:Fds
        endIdx = min(Fds, startIdx + batch_size - 1);

        raw_start = ds_frames(startIdx);
        raw_end   = ds_frames(endIdx);
        raw = reader.read_range(raw_start, raw_end);

        keep_idx = ds_frames(startIdx:endIdx) - raw_start + 1;
        raw = raw(:, :, keep_idx);

        % Repair before either resize, using the masks the scan already fixed.
        raw = repair_frames(raw, defects);

        raw = apply_spatial_ds(raw, opt.spatial_ds, [d1, d2]);
        chunk = cast(raw, target_class);

        payload = {'Y', chunk};
        if startIdx == 1
            % The record goes into the options saved in THIS file, so the later
            % stages can see that this recording has been checked without
            % consulting a struct that is shared by every file in the call.
            file_options = CaliAli_options;
            file_options.defects_repaired = defects;
            payload = [payload, {'CaliAli_options', file_options}]; %#ok<AGROW>
        end
        CaliAli_save({fullFileName, k, startIdx, endIdx, outFile}, payload{:});

        clear raw chunk
    end
    F(k) = Fds;
end

if all(F == 1000)
    cprintf('-comment', ['All files appear to be 1000-frame batches.\n' ...
        'If these are split files from the same session, they need to be concatenated following the instructions below:\n']);
    cprintf('Hyperlinks', 'https://caliali-pv.github.io/CaliAli/latest/Processing_split_data/\n');
end

opt.output_files = opt.output_files(:)';
CaliAli_options.downsampling = opt;

end


function defects = scan_for_defects(reader, ds_frames, opt)
%% Read a sample spread across the recording and decide the defect masks once.
if ~isfield(opt,'repair_defects') || isempty(opt.repair_defects)
    opt.repair_defects = true;
end
[d1r, d2r] = deal(reader.size(1), reader.size(2));
defects = struct('dead', false(d1r,d2r), 'rows', 1:d1r, 'cols', 1:d2r, ...
    'n_dead', 0, 'border_px', 0, 'frames_used', 0);
if ~opt.repair_defects
    return
end

% HOW MANY FRAMES THIS READS, AND WHY THAT NUMBER.
%
% At most 120, spread evenly from the first frame to the last, and each read
% singly rather than as a block.
%
% WHY 120 AND NOT THE WHOLE RECORDING. What is being decided here is which
% pixels never change and where the frame stops carrying data -- both properties
% of the sensor and the field of view, not of any one moment. A pixel that is
% dead is dead in every frame, so its variance is already zero in a hundred of
% them, and reading a hundred thousand would say the same thing far more slowly.
% The cost is bounded: 120 frames whatever the recording length, so a ten minute
% session and a two hour one pay the same.
%
% WHY 120 AND NOT TEN. Variance estimated from a handful of frames is noisy
% enough that quiet tissue starts to look dead. A hundred or so puts the
% estimate well clear of that, and the difference between 120 and 1200 is not
% worth the read.
%
% WHY SPREAD, NOT THE FIRST 120. The start of a recording is its least
% representative part -- the lamp is still settling, the animal has usually just
% been connected, and any border left by an earlier motion correction is at its
% narrowest before the session has had time to drift. Sampling the whole span
% costs the same and describes the whole recording.
%
% WHY FRAME BY FRAME. Reading 120 consecutive frames would be one fast block,
% but they would all come from the same moment. These are scattered by
% construction, so each is its own read; that is the price of the spread.
n = min(numel(ds_frames), 120);
pick = ds_frames(unique(round(linspace(1, numel(ds_frames), n))));
sample = zeros(d1r, d2r, numel(pick));
for k = 1:numel(pick)
    f = reader.read_range(pick(k), pick(k));
    sample(:,:,k) = double(f(:,:,1));
end

s = struct();
if isfield(opt,'dead_pixel_factor'), s.dead_pixel_factor = opt.dead_pixel_factor; end
if isfield(opt,'repair_borders'),    s.repair_borders    = opt.repair_borders;    end
defects = find_frame_defects(sample, s);
defects.stage = 'downsampling';
defects.spatial_ds_applied = false;   % found on raw frames, the reliable case

if defects.n_dead > 0 || defects.border_px > 0
    cprintf('-comment', ...
        '  sensor defects: %d dead pixels, border %d px\n', ...
        defects.n_dead, defects.border_px);
end
end


function reader = build_reader(fullFileName, ext, opts)
if nargin < 3 || isempty(opts)
    opts = struct();
end
if ~isfield(opts, 'prefer_ffmpeg'), opts.prefer_ffmpeg = true; end
if ~isfield(opts, 'batch_size'), opts.batch_size = []; end
ext = lower(ext);
switch true
    case contains(ext, {'.avi', '.m4v', '.mp4'})
        v = VideoReader(fullFileName);
        reader.nFrames = v.NumFrames;
        reader.size = [v.Height, v.Width];
        reader.fps = v.FrameRate;
        f0 = read(v, 1);
        if size(f0, 3) == 3
            f0 = rgb2gray(f0);
        end
        reader.src_class = class(f0);
        reader.read_range = @(s, e) read_video_range(v, s, e);
        if opts.prefer_ffmpeg && ismac
            ffmpegPath = find_packaged_ffmpeg();
            if ~isempty(ffmpegPath)
                bitDepth = class_to_bitdepth(reader.src_class);
                reader.read_range = @(s, e) read_video_range_ffmpeg(fullFileName, s, e, reader.size, reader.fps, ffmpegPath, bitDepth);
            end
        end
    case contains(ext, '.isxd')
        movieObj = open_isxd_movie(fullFileName);
        reader.nFrames = movieObj.timing.num_samples;
        f0 = movieObj.get_frame_data(0);
        reader.size = [size(f0, 1), size(f0, 2)];
        reader.src_class = class(f0);
        reader.read_range = @(s, e) read_isxd_range(movieObj, s, e);
    case contains(ext, '.tif')
        info = imfinfo(fullFileName);
        reader.nFrames = numel(info);
        reader.size = [info(1).Height, info(1).Width];
        reader.src_class = bitdepth_to_class(info(1).BitDepth);
        reader.read_range = @(s, e) read_tiff_range(fullFileName, s, e, reader.size);
        % Fast TIFF preloading is avoided in batch mode to keep memory lower
        if isfield(opts, 'batch_size') && ~isempty(opts.batch_size) && opts.batch_size < reader.nFrames
            if exist('cprintf', 'file')
                cprintf('-comment', 'Skipping fast TIFF preload for %s to keep batch memory lower.\n', fullFileName);
            else
                fprintf(1, 'Skipping fast TIFF preload for %s to keep batch memory lower.\n', fullFileName);
            end
        end
    case contains(ext, '.h5')
        info = h5info(fullFileName, '/Object');
        dims = info.Dataspace.Size;
        reader.nFrames = dims(3);
        reader.size = [dims(1), dims(2)];
        sample = h5read(fullFileName, '/Object', [1 1 1], [1 1 1]);
        reader.src_class = class(sample);
        reader.read_range = @(s, e) cast(h5read(fullFileName, '/Object', [1 1 s], [dims(1) dims(2) e - s + 1]), reader.src_class);
    otherwise
        error('Unsupported file format. Supported formats are: .avi, .m4v, .mp4, .isxd, .tif, .tiff, .h5');
end
end


function frames = read_video_range(v, start_idx, end_idx)
n = end_idx - start_idx + 1;
frame1 = read(v, start_idx);
if size(frame1, 3) == 3
    frame1 = rgb2gray(frame1);
end
frames = zeros(v.Height, v.Width, n, class(frame1));
frames(:, :, 1) = frame1;
for i = 1:n
    if i == 1
        continue
    end
    idx = start_idx + i - 1;
    f = read(v, idx);
    if size(f, 3) == 3
        f = rgb2gray(f);
    end
    frames(:, :, i) = f;
end
end


function frames = read_tiff_range(path, start_idx, end_idx, sz)
n = end_idx - start_idx + 1;
sample = imread(path, start_idx);
frames = zeros(sz(1), sz(2), n, class(sample));
frames(:, :, 1) = sample;
for i = 1:n
    if i == 1
        continue
    end
    frames(:, :, i) = imread(path, start_idx + i - 1);
end
end


function frames = read_isxd_range(movieObj, start_idx, end_idx)
n = end_idx - start_idx + 1;
f0 = movieObj.get_frame_data(start_idx - 1);
frames = zeros(size(f0, 1), size(f0, 2), n, class(f0));
frames(:, :, 1) = f0;
for i = 2:n
    frames(:, :, i) = movieObj.get_frame_data(start_idx + i - 2);
end
end


function mObj = open_isxd_movie(inputFilePath)
try
    mObj = isx.Movie.read(inputFilePath);
    return;
catch
    % Attempt to locate the Inscopix MATLAB API if not already on the path
    if ismac
        baseInscopixPath = '/Applications/Inscopix Data Processing.app/Contents/API/MATLAB';
    elseif isunix
        baseInscopixPath = './Inscopix Data Processing.linux/Contents/API/MATLAB';
    elseif ispc
        baseInscopixPath = 'C:\Program Files\Inscopix\Data Processing';
    else
        baseInscopixPath = './';
    end

    if ~exist(baseInscopixPath, 'dir')
        baseInscopixPath = uigetdir('.', 'Enter path to Inscopix Data Processing installation folder (contains +isx)');
    end
    if exist(baseInscopixPath, 'dir')
        addpath(baseInscopixPath);
    end
    mObj = isx.Movie.read(inputFilePath);
end
end


function out = apply_spatial_ds(raw_keep, spatial_ds, out_sz)
if spatial_ds > 1
    num_keep = size(raw_keep, 3);
    out = zeros(out_sz(1), out_sz(2), num_keep, 'like', raw_keep);
    scale = 1/spatial_ds;
    for ii = 1:num_keep
        out(:, :, ii) = imresize(raw_keep(:, :, ii), scale, 'bilinear');
    end
else
    out = raw_keep;
end
end


function ffmpegPath = find_packaged_ffmpeg()
ffmpegPath = '';
if exist('loadGrayAVIwithFFmpeg', 'file') == 2
    p = which('loadGrayAVIwithFFmpeg');
    ffmpegPath = fullfile(fileparts(p), 'ffmpeg');
    if exist(ffmpegPath, 'file') ~= 2
        ffmpegPath = '';
    else
        if ismac
            fileattrib(ffmpegPath, '+x');
        end
    end
end
end


function frames = read_video_range_ffmpeg(videoFile, start_idx, end_idx, vid_size, fps, ffmpegPath, bitDepth)
if nargin < 6 || isempty(ffmpegPath)
    error('FFmpeg path is required for ffmpeg-based reading.');
end
if nargin < 5 || isempty(fps)
    fps = 30;
end
if nargin < 7 || isempty(bitDepth)
    bitDepth = 8;
end
start_sec = (start_idx - 1) / fps;
n = end_idx - start_idx + 1;

rawFile = [tempname '.raw'];
if bitDepth > 8
    pixFmt = 'gray16le';
    readType = 'uint16';
else
    pixFmt = 'gray';
    readType = 'uint8';
end
cmd = sprintf('\"%s\" -v error -ss %.6f -i \"%s\" -vframes %d -vf format=%s -f rawvideo -pix_fmt %s \"%s\"', ...
    ffmpegPath, start_sec, videoFile, n, pixFmt, pixFmt, rawFile);
status = system(cmd);
if status ~= 0
    error('FFmpeg failed when reading %s (frames %d-%d).', videoFile, start_idx, end_idx);
end

fid = fopen(rawFile, 'rb');
rawData = fread(fid, inf, readType);
fclose(fid);
delete(rawFile);

expected = vid_size(2) * vid_size(1) * n;
if numel(rawData) < expected
    n = floor(numel(rawData) / (vid_size(1) * vid_size(2)));
    rawData = rawData(1:vid_size(1) * vid_size(2) * n);
end
if numel(rawData) > expected
    rawData = rawData(1:expected);
end

frames = reshape(rawData, [vid_size(2), vid_size(1), n]);
frames = permute(frames, [2, 1, 3]);
frames = cast(frames, bitdepth_to_class(bitDepth));
end


function batch_size = resolve_batch_size(batch_sz, out_sz, Fds)
% One input file is one session at this stage, so 'per_session' and 'all_frames'
% ask for the same thing: the whole file in one batch. A legacy 0 has always
% meant that here too.
[mode, n] = resolve_batch_mode(batch_sz, 'all_frames');
switch mode
    case 'fixed'
        batch_size = min(Fds, n);
    case {'all_frames', 'per_session'}
        batch_size = Fds;
    otherwise   % 'auto'
        try
            [batch_size, ~] = compute_auto_batch_size('auto', [], [out_sz(1), out_sz(2)]);
        catch
            % Fallback if compute_auto_batch_size unavailable
            batch_size = min(Fds, 30000);
        end
        batch_size = min(max(1, batch_size), Fds);
end
end


function redo = existing_output_needs_redo(outFile)
%% Is a cached output incomplete, so it has to be written again?
% The test lives in check_mat_video, which every stage that validates a video
% file uses, so there is one definition of "incomplete" rather than a copy per
% caller. It reads metadata plus a single frame.
[status, reason] = check_mat_video(outFile);
redo = strcmp(status, 'corrupt');

if redo
    if exist('cprintf', 'file')
        cprintf('_red', 'Existing file %s is probably corrupted (%s). Re-running downsampling.\n', outFile, reason);
    else
        fprintf(2, 'Existing file %s is probably corrupted (%s). Re-running downsampling.\n', outFile, reason);
    end
    if isfile(outFile)
        delete(outFile);
    end
end
end


function warn_file_exists(outFile)
if exist('cprintf', 'file')
    cprintf('_red', 'File %s already exist in destination folder!\n', outFile);
else
    fprintf(2, 'File %s already exist in destination folder!\n', outFile);
end
end


function opt = process_folder_batch(fullFileName, opt,  CaliAli_options)
files = dir([fullFileName, filesep, '*', opt.file_extension]);
if isempty(files)
    warning('No files with extension %s found in %s', opt.file_extension, fullFileName);
    return
end


[~,index] = natsortfiles({files.name});
files=files(index);

opt_local = opt;
opt_local.input_files = fullfile({files.folder}, {files.name})';

sub_options = CaliAli_options;
sub_options.downsampling = opt_local;
sub_options = CaliAli_downsample(sub_options);

out_dir = fileparts(sub_options.downsampling.output_files{1});
[parent_dir, session_dir] = fileparts(out_dir);
if isempty(parent_dir)
    parent_dir = out_dir;
end
if ~exist(parent_dir, 'dir')
    mkdir(parent_dir);
end
outpath = fullfile(parent_dir, [session_dir '_con.mat']);
CaliAli_concatenate_files(outpath, sub_options.downsampling.output_files);

opt.output_files = [opt.output_files, {outpath}];
end


function bd = class_to_bitdepth(cls)
switch cls
    case {'uint16', 'int16'}
        bd = 16;
    otherwise
        bd = 8;
end
end


function cls = bitdepth_to_class(bitDepth)
if bitDepth > 8
    cls = 'uint16';
else
    cls = 'uint8';
end
end


function cls = resolve_output_class(opt)
%% The datatype this stage writes. Shared with every other writing stage so the
% allowed set and the validation are defined in one place.
cls = resolve_stage_class(opt);
end

function warn_if_cast_destroys(sample, cls, fname)
%% Say so when the conversion would throw away most of the range.
% This is the failure reported in issue #35: uint8 saturates rather than
% rescales, so a recording whose values exceed the target range loses
% everything above it, irreversibly and silently. Casting is still performed --
% the class is the user's choice -- but not quietly.
if isempty(sample) || strcmpi(cls,'single') || strcmpi(cls,'double')
    return
end
sample = double(sample(:));
hi = max(sample);
lim = double(intmax(cls));
if hi > lim
    cprintf('_red', ['%s: values reach %.3g but %s saturates at %.0f. Everything ' ...
        'above that becomes %.0f. Set downsampling.output_class to a wider type.\n'], ...
        fname, hi, cls, lim, lim);
elseif isfloat(sample) && hi <= 1
    cprintf('_red', ['%s: values only reach %.3g, so casting to %s leaves almost ' ...
        'no levels. Scale the recording first, or set downsampling.output_class ' ...
        'to single.\n'], fname, hi, cls);
end
end
