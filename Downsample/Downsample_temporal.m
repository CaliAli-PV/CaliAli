function Downsample_temporal(ds_f,theFiles)

if ~exist('ds_f','var')
    ds_f = 2;
end

if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
end


for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,filesep,name,'_tds','.h5');
    if ~isfile(out)
        V=h5read(fullFileName,'/Object');
        V = V(:, :, 1:ds_f:end);
        saveash5(v2uint16(V),out);
    else
        fprintf(1, 'File %s already exist in destination folder!\n', out);
    end
end
     