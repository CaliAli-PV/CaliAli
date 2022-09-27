function Downsample_avi(outpath,ds_f)

if ~exist('outpath','var')
outpath = [];
end

if ~exist('ds_f','var')
ds_f = 2;
end

theFiles = uipickfiles('REFilter','\.avi$');

for k=1:length(theFiles)  
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    temp=load_avi(fullFileName);
    upd = textprogressbar(size(temp,3),'updatestep',30);
    
    [filepath,name]=fileparts(fullFileName);
    if isempty(outpath)
        out=strcat(filepath,'\',name,'_ds','.h5');
    else
        out=strcat(outpath,'\',name,'_ds','.h5');
    end
    
    for i=1:size(temp,3)
        upd(i);
        vid(:,:,i)=imresize(temp(:,:,i),1/ds_f,'bilinear');
    end
    saveash5(vid,out);  

end