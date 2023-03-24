function concatenate_videos(theFiles)

%% this code concatenate video without inter-session registration
if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
elseif isempty(theFiles)
    theFiles = uipickfiles('FilterSpec','*.h5');
end

outV=[];
for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    V=h5read(fullFileName,'/Object');
    outV=cat(3,outV,V);
end
    out=strcat(filepath,'\',name,'_conc','.h5');
%% save MC video as .h5
saveash5(outV,out);
end

