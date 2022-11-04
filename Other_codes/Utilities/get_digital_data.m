function Do=get_digital_data()
theFiles = uipickfiles('FilterSpec','*.gpio');

for i=1:size(theFiles,2)
       fname = theFiles{1,i};
    [filepath,name,~] = fileparts(fname);
    fid = fopen(fname);
    raw = downsample(fread(fid,[52 inf],'uint8=>uint8')',1000);
    fclose(fid);
    INFo=h5info([filepath,'\',name,'_ds.h5']);
    d=INFo.Datasets.Dataspace.Size;
    do=uint8(resample(double(raw),d(3),size(raw,1)));
    Do{i}=do;
end


