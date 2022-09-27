function Downsample_Inscopix(outpath,ds_f)

if ~exist('outpath','var')
outpath = [];
end

if ~exist('ds_f','var')
ds_f = 4;
end

theFiles = uipickfiles('REFilter','\.isxd$');

for k=1:length(theFiles)  
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    ISXD2h5(fullFileName,ds_f,outpath)
end