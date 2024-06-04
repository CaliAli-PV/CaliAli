function Downsample_avi(ds_f,outpath,theFiles)
if ~exist('outpath','var')
    outpath = [];
end

if ~exist('ds_f','var')
    ds_f = 1;
end

if ~exist('theFiles','var')
    theFiles = uipickfiles('REFilter','\.avi$|\.m4v$|\.mp4$');
end


for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);

    [filepath,name]=fileparts(fullFileName);
    if isempty(outpath)
        out=strcat(filepath,filesep,name,'_ds','.h5');
    else
        out=strcat(outpath,filesep,name,'_ds','.h5');
    end
    if ~isfile(out)
        temp=load_avi(fullFileName);
        vid=[];
        for i=progress(1:size(temp,3))
            vid(:,:,i)=imresize(temp(:,:,i),1/ds_f,'bilinear');
        end
        saveash5(v2uint8(vid),out);
    else
        fprintf(1, 'File %s already exist in destination folder!\n', out);
    end
end