function out=CaliAli_concatenate_files(outpath,inputh,CaliAli_options)
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


