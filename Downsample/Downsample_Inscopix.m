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
    ISXD2h5(fullFileName,ds_f,outpath)
end