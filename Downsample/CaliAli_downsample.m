function CaliAli_options=CaliAli_downsample(varargin)
%% CaliAli_downsample: Downsample input video files in time and space.
%
% This function performs temporal and spatial downsampling on selected video files.
% Supported formats include .avi, .m4v, .mp4, .tif, .tiff, .isxd, and .h5.
%
% Inputs:
%   varargin - Variable input arguments, which are parsed into CaliAli_options.
%              The details of the CaliAli_options structure can be found in 
%              CaliAli_demo_parameters().
%
% Outputs:
%   CaliAli_options - Updated structure containing the downsampling parameters.
%   Saved output files - Downsampled video files are saved as .mat files with
%                        the suffix "_ds" in the original file directory.
%
% Usage:
%   CaliAli_options = CaliAli_downsample();  % Interactive file selection
%   CaliAli_options = CaliAli_downsample(CaliAli_options);  % Using predefined options
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

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
                temp = ISXD2h5(fullFileName);
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
        % Save CaliAli parameters
        Y=v2uint8(Y)+1;
        CaliAli_options.downsampling=opt; 
        CaliAli_save(opt.output_files{k}(:),Y,CaliAli_options);
        fprintf(1, 'File saved in %s\n',opt.output_files{k});     
    else
        % If the output file already exists, skip processing and print a message
        cprintf('_red', 'File %s already exist in destination folder!\n', opt.output_files{k});
    end
end

CaliAli_options.downsampling=opt; 