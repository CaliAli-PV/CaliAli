function out=CaliAli_concatenate_files(outpath,inputh,CaliAli_options)
%% CaliAli_concatenate_files: Concatenate multiple video files into a single file.
%
% This function merges multiple .mat video files into a single output file.
% The resulting concatenated video is saved in the specified output path.
%
% Inputs:
%   outpath         - (Optional) String specifying the output file path.
%                     If not provided, a default name is generated.
%   inputh          - (Optional) Cell array containing paths to input .mat files.
%                     If not provided, a file selection dialog is prompted.
%   CaliAli_options - (Optional) Structure containing processing options.
%
% Outputs:
%   out - Path to the saved concatenated video file.
%
% Usage:
%   out = CaliAli_concatenate_files();  % Interactive file selection
%   out = CaliAli_concatenate_files(outpath, inputh, CaliAli_options);  % Using predefined parameters
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

if ~exist('outpath','var')
    outpath = [];
end


if ~exist('inputh','var')
    inputh = uipickfiles('FilterSpec','*.mat');
end

if ~exist('CaliAli_options','var')
    CaliAli_options = [];
end



[filepath,name]=fileparts(inputh{end});
if isempty(outpath)
    outpath=strcat(filepath,filesep,name,'_con','.mat');
end
out=outpath;

% --- Expected frame count = sum over input segments (metadata only, cheap) ---
% This is the authoritative length of the concatenated recording. Counting it
% up front lets us both validate a cached output and verify the rebuild.
segment_F = zeros(1,numel(inputh));
for k=1:numel(inputh)
    segment_F(k) = safe_count_frames(inputh{k});
    if segment_F(k) <= 0
        error('CaliAli:concatenate:badInput', ...
            ['Input segment "%s" has no readable frames (likely an interrupted ' ...
            'downsample). Re-run downsampling for this session before concatenating.'], ...
            inputh{k});
    end
end
expected_frames = sum(segment_F);

% --- Reuse an existing output ONLY if it is complete AND matches the inputs ---
% Guards against the stale/partial-concatenation failure mode: if a previous
% run was interrupted, or was run before all split .avi segments were present,
% the cached _con.mat has the wrong frame count and must be rebuilt rather than
% silently reused.
if isfile(outpath)
    existing_frames = safe_count_frames(outpath);
    last_zero = last_frame_is_zero(outpath);
    if existing_frames == expected_frames && ~last_zero
        fprintf(1, 'File %s already exists and matches its %d input segments (%d frames). Skipping.\n', ...
            out, numel(inputh), expected_frames);
        return
    end
    if existing_frames ~= expected_frames
        fprintf(2, ['Existing file %s has %d frames but its %d input segments sum to %d. ' ...
            'It is stale or incomplete and will be rebuilt.\n'], ...
            out, existing_frames, numel(inputh), expected_frames);
    else
        fprintf(2, 'Existing file %s appears incomplete (empty last frame). Rebuilding.\n', out);
    end
    delete(outpath);
end

% --- Build the concatenated file ---
vid=cell(1,numel(inputh));
for k=progress(1:numel(inputh))
    vid{k}=CaliAli_load(inputh{k},'Y');
end
Y=cat(3,vid{:});

% --- Guard: the assembled stack must contain every input frame ---
if size(Y,3) ~= expected_frames
    error('CaliAli:concatenate:frameMismatch', ...
        'Concatenated frame count (%d) does not match the sum of inputs (%d).', ...
        size(Y,3), expected_frames);
end

CaliAli_save(outpath(:),Y,CaliAli_options);
fprintf(1, 'Saved concatenated file %s (%d frames from %d segments).\n', ...
    out, expected_frames, numel(inputh));


