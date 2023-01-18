function Downsample_Inscopix(outpath,ds_f,theFiles)

if ~exist('outpath','var')
    outpath = [];
end

if ~exist('ds_f','var')
    ds_f = 4;
end
if ~exist('theFiles','var')
    theFiles = uipickfiles('REFilter','\.isxd$');
end

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    [~,name]=fileparts(theFiles{k});
    if ~isfile([outpath,'\',name,'_ds.h5'])
        ISXD2h5(fullFileName,ds_f,outpath)
    else
        fprintf(1, 'File %s already exist in destination folder\n', [name,'.h5']);
    end
end