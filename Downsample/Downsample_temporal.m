function out = Downsample_temporal(ds_f,outpath,theFiles)
if ~exist('outpath','var')
    outpath = [];
end

if ~exist('ds_f','var')
    ds_f = 1;
end

if ~exist('theFiles','var')
     theFiles = uipickfiles('FilterSpec','*.h5');
end

if ds_f>1
for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);

    [filepath,name]=fileparts(fullFileName);
    if isempty(outpath)
        out{k}=strcat(filepath,filesep,name,'_dst','.h5');
    else
        out{k}=strcat(outpath,filesep,name,'_dst','.h5');
    end
    if ~isfile(out{k})
        vid=h5read(fullFileName,'/Object');
        vid=vid(:,:,1:ds_f:end);
        saveash5(v2uint8(vid),out{k});
    else
        fprintf(1, 'File %s already exist in destination folder!\n', out{k});
    end
end

else
    fprintf(1, 'Temporal downsampling factor is 1. Change ''ds_f''\n');
end
