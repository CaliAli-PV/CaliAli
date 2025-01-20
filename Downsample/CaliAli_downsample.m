function CaliAli_options=CaliAli_downsample(varargin)
% CaliAli_downsample downsamples video files spatially and temporally.
%
%   out = CaliAli_downsample(varargin)
%
%   This function allows you to downsample video files (AVI, MP4, ISXD,
%   TIFF) by specifying spatial and temporal downsampling factors. It uses
%   the `downsampling_parameters` function to handle input arguments and
%   provides flexibility in specifying downsampling options.
%
%   Example usage:
%       out = CaliAli_downsample('spatial_ds', 2, 'temporal_ds', 2);
%       This will downsample the video by a factor of 2 in both spatial
%       dimensions and temporally (taking every other frame).
%
%   Inputs (using Parameter-Value pairs):
%       'spatial_ds'    - Spatial downsampling factor (default: 1)
%       'temporal_ds'   - Temporal downsampling factor (default: 1)
%       'input_files'  - Cell array of input video file paths
%                         (default: 'pickup' - prompts user to select files)
%       'out_path'       - Output directory (default: same as input file)
%
%   Outputs:
%       out             - Cell array of output file paths
% Parse input arguments
CaliAli_options= CaliAli_parameters(varargin{:});
opt = CaliAli_options.downsampling;
% If 'input_files' is set to 'pickup', prompt the user to select files

if isempty(opt.input_files)
    opt.input_files = uipickfiles('REFilter','\.h5$|\.avi$|\.m4v$|\.mp4$|\.tif$|\.tiff$|\.isxd$');
end
% Loop through each selected file
for k = 1:length(opt.input_files)
    fullFileName = opt.input_files{k};  % Get the full path of the current file
    fprintf(1, 'Now reading %s\n', fullFileName);  % Print the file being processed
    if isfolder(fullFileName) % check if inputs correspond to folders or files
        process_folder(fullFileName,opt)
        continue
    end
    % Extract the file path and name
    [filepath, name,ext] = fileparts(fullFileName);
    % Construct the output file path
    opt.output_files{k} = strcat(filepath, filesep, name, '_ds', '.mat');
    % Check if the output file already exists
    if ~isfile(opt.output_files{k})
        [~,~,ext]=fileparts(fullFileName);
        switch true
            case contains('.avi .m4v .mp4',ext,'IgnoreCase',true)
                temp = load_avi(fullFileName);  % Load the AVI file
            case contains('.isxd',ext,'IgnoreCase',true)
                temp = ISXD2h5(inputFilePath);
            case contains(ext,'.tif','IgnoreCase',true)
                temp=tiff_reader_fast(fullFileName);  
            case contains(ext,'.h5','IgnoreCase',true)
                temp=h5read(fullFileName,'/Object');  
            otherwise
                error('Unsupported file format. Supported formats are: .avi, .m4v, .mp4, .isxd, .tif, .tiff');
        end
        % Perform temporal downsampling by selecting frames at intervals of 'temporal_ds'
        if opt.temporal_ds>1
            temp = temp(:, :, 1:opt.temporal_ds:end);
        end
        % Initialize an empty array to store the downsampled video
        Y = [];
        % Downsample each frame spatially
        if opt.spatial_ds>1
            for i = progress(1:size(temp, 3), 'Title', 'Resizing')
                Y(:, :, i) = imresize(temp(:, :, i), 1/opt.spatial_ds, 'bilinear');
            end
        else
        Y=temp;
        end
        clear temp
        % Save the downsampled video as an HDF5 file
        % Save CaliAli parameters (likely related to camera alignment or other metadata)
        Y=v2uint8(Y)+1;
        CaliAli_options.downsampling=opt;
        CaliAli_save(opt.output_files{k}(:),Y,CaliAli_options);
        fprintf(1, 'File saved in %s\n',opt.output_files{k});     
    else
        % If the output file already exists, skip processing and print a message
        fprintf(1, 'File %s already exist in destination folder!\n', opt.output_files{k});
    end
end

CaliAli_options.downsampling=opt;