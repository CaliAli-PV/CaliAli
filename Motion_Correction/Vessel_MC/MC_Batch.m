function MC_Batch()

theFiles = uipickfiles('FilterSpec','*.h5');

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_mc','.h5');
    if ~isfile(out)
        V=h5read(fullFileName,'/Object');
        [V,~]=motion_correct_PV(V); %% Rigid MC
        Mr=MC_NR(V);
        %     
        %% save MC video as .h5
        saveash5(Mr,out);
    end
end