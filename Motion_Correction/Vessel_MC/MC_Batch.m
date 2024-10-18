function MC_Batch(theFiles,do_nr,varargin)

if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
elseif isempty(theFiles)
    theFiles = uipickfiles('FilterSpec','*.h5');
end
opt=int_var(cat(2,varargin,{'theFiles',theFiles}));
if ~exist('do_nr','var')
    do_nr = 0;
end

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,filesep,name,'_mc','.h5');
    if ~isfile(out)
        V=h5read(fullFileName,'/Object');
        [V,BV]=motion_correct_PV(V+1,opt); %% Rigid MC
        if do_nr
            %         Mr=MC_NR(V);
            V=MC_NR_not_used_testing(V,BV,[],opt);
        end
        %
        V=interpolate_dropped_frames(V);
        V=square_borders(V,0);
        %
        %% save MC video as .h5
        saveash5(V,out);
    end
end

