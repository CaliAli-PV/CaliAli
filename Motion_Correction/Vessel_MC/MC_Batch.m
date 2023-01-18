function MC_Batch(theFiles)
if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
end

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_mc','.h5');
    if ~isfile(out)
        V=h5read(fullFileName,'/Object');
        [V,~]=motion_correct_PV(V); %% Rigid MC
        %Mr=MC_NR(V);
        Mr=MC_NR_not_used_testing(V);
        Mr=interpolate_dropped_frames(Mr);
        Mr=square_borders(Mr,0);
        %
        %% save MC video as .h5
        saveash5(Mr,out);
    end
end

