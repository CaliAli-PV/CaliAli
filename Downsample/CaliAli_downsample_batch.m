function CaliAli_options=CaliAli_downsample_batch(CaliAli_options)
%% CaliAli_downsample_batch: Downsample input video files in batches.
%
% This function mirrors CaliAli_downsample but processes data in chunks to
% limit memory usage. Outputs are intended to be identical to the original
% downsampling workflow.
%
% Usage:
%   CaliAli_options = CaliAli_downsample_batch();
%   CaliAli_options = CaliAli_downsample_batch(CaliAli_options);
%   CaliAli_options = CaliAli_downsample_batch(CaliAli_options, batch_sz);
%
% Notes:
%   - batch_sz: number of downsampled frames per batch. Use a numeric value,
%     0/Inf to process all at once, or 'auto' to pick a heuristic size.

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
        warn_file_exists(outFile);
        continue
    end

    reader = build_reader(fullFileName, ext);
    ds_frames = int32(1:opt.temporal_ds:reader.nFrames);
    Fds = numel(ds_frames);

    first_frame = reader.read_range(1, 1);
    [d1, d2] = size(imresize(double(first_frame(:, :, 1)), 1/opt.spatial_ds, 'bilinear'));

    batch_size = resolve_batch_size(batch_sz, [d1, d2], Fds);
    reader = build_reader(fullFileName, ext, struct('batch_size', batch_size));

    target_class = reader.src_class;
    if isempty(target_class)
        target_class = 'uint16';
    end
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

        raw = apply_spatial_ds(raw, opt.spatial_ds, [d1, d2]);
        chunk = cast(raw, target_class);

        payload = {'Y', chunk};
        if startIdx == 1
            payload = [payload, {'CaliAli_options', CaliAli_options}]; %#ok<AGROW>
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
if isnumeric(batch_sz)
    if isinf(batch_sz) || batch_sz <= 0
        batch_size = Fds;
    else
        batch_size = min(Fds, ceil(batch_sz));
    end
    return
end

if ischar(batch_sz) || (isstring(batch_sz) && isscalar(batch_sz))
    if strcmpi(batch_sz, 'auto')
        try
            [batch_size, ~] = compute_auto_batch_size('auto', [], [out_sz(1), out_sz(2)]);
        catch
            % Fallback if compute_auto_batch_size unavailable
            batch_size = min(Fds, 30000);
        end
        batch_size = min(max(1, batch_size), Fds);
        return
    end
end

batch_size = min(Fds, 10000); % fallback default
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

opt_local = opt;
opt_local.input_files = fullfile({files.folder}, {files.name})';

sub_options = CaliAli_options;
sub_options.downsampling = opt_local;
sub_options = CaliAli_downsample_batch(sub_options);

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
