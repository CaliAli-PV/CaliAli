function scout_mat2h5()

theFiles = uipickfiles('FilterSpec','*.mat');

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'.h5');
    load(fullFileName,'Y');
    saveash5(Y,out);
end
    
       
