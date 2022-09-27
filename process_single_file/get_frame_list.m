function get_frame_list(theFiles,out)
% get_CnPNR_from_video(4);
if ~exist('theFiles','var')
theFiles = uipickfiles('FilterSpec','*.h5');
end

F=zeros(length(theFiles),1);
for k=1:length(theFiles)
    fullFileName = theFiles{k};
    V=h5info(fullFileName);
    F(k)=V.Datasets.Dataspace.Size(1,3);
end

[filepath,name]=fileparts(fullFileName);
if ~exist('out','var')
out=strcat(filepath,'\',name,'.mat');
end

if ~isfile(out) 
save(out,'F');    
else
save(out,'F','-append');
end