function simple_concatenation()

if ~exist('outpath','var')
outpath = [];
end

theFiles = uipickfiles('REFilter','\.h5$');
out=[];
for k=1:length(theFiles)  
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    v=h5read(fullFileName,'/Object');
    out=cat(3,out,v);
end
[filepath,name,ext] = fileparts(fullFileName);
saveash5(out,[filepath,'\',name,'_all',ext]);