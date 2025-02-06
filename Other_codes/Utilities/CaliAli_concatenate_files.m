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
    out=strcat(filepath,filesep,name,'_con','.mat');
end

vid=[];
if ~isfile(outpath)
    for k=progress(1:length(inputh))
        fullFileName = inputh{k};
        vid{k}=CaliAli_load(fullFileName,'Y');     
    end
    Y=cat(3,vid{:});
    CaliAli_save(outpath(:),Y,CaliAli_options);
else
    fprintf(1, 'File %s already exist in destination folder!\n', out);
end


