function out=concatenate_files_CaliAli(outpath,theFiles)
if ~exist('outpath','var')
    outpath = [];
end


if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
end


[filepath,name]=fileparts(theFiles{end});
if isempty(outpath)
    out=strcat(filepath,filesep,name,'_con','.h5');
else
    out=strcat(outpath,filesep,name,'_con','.h5');
end
vid=[];
if ~isfile(out)
    for k=progress(1:length(theFiles))
        fullFileName = theFiles{k};
        vid{k}=h5read(fullFileName,'/Object');        
    end
    vid=cat(3,vid{:});
    saveash5(v2uint8(vid),out);
else
    fprintf(1, 'File %s already exist in destination folder!\n', out);
end


