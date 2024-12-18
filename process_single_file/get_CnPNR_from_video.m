function get_CnPNR_from_video(gSig,theFiles,F,n_enhanced,batch_mode)
% get_CnPNR_from_video(4);
if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
elseif isempty(theFiles)
    theFiles = uipickfiles('FilterSpec','*.h5');
end

if ~exist('n_enhanced','var')
    n_enhanced = 0;
elseif isempty(theFiles)
    n_enhanced = 0;
end

if ~exist('F','var')
    F=[];
end

if ~exist('batch_mode','var')
    batch_mode=0;
end

if batch_mode==0
%% Calculate PNR and Cn image loading the whole video
    for k=1:length(theFiles)
        fullFileName = theFiles{k};
        fprintf(1, 'Calculating PNR & Cn image for %s\n', fullFileName);
        V=h5read(fullFileName,'/Object');
        [path,name]=fileparts(fullFileName);
        try
            load([path,'\',name,'.mat'],'F');
        catch
        end
        if ~isempty(F)
            [Cn_all,Cn,PNR]=get_PNR_coor_greedy_PV(V,gSig,F,n_enhanced);
        else
            F=size(V,3);
            [Cn_all,Cn,PNR]=get_PNR_coor_greedy_PV(V,gSig,F,n_enhanced);
        end
        Cn=mat2gray(Cn);
        [filepath,name]=fileparts(fullFileName);
        out=strcat(filepath,'\',name,'.mat');

        if ~isfile(out)
            save(out,'Cn_all','Cn','PNR','gSig','n_enhanced','F');
        else
            save(out,'Cn_all','Cn','PNR','gSig','n_enhanced','F','-append');
        end
    end
else
    %% Calculate PNR and Cn image in batch-mode
 for k=1:length(theFiles)
        fullFileName = theFiles{k};
        fprintf(1, 'Calculating PNR & Cn image for %s in Batch mode\n', fullFileName);
        [path,name]=fileparts(fullFileName);
        try
            load([path,'\',name,'.mat'],'F');
        catch
        end
        if ~isempty(F)
            ix=0;
            info = h5info(fullFileName);
            ds=info.Datasets.Dataspace.Size;
            for i=progress(1:size(F,2))
                V=h5read(fullFileName,'/Object',[1,1,ix+1],[ds(1),ds(2),F(i)]);
                [Cn_all{i},~,PNR{i}]=get_PNR_coor_greedy_PV(V,gSig,F(i),n_enhanced);
                ix=ix+F(i);
            end
            Cn_all=cat(3,Cn_all{:});
            Cn=mat2gray(max(Cn_all,[],3));
            PNR=max(cat(3,PNR{:}),[],3);
        else
            V=h5read(fullFileName,'/Object');
            F=size(V,3);
            [Cn_all,Cn,PNR]=get_PNR_coor_greedy_PV(V,gSig,F,n_enhanced);
            Cn=mat2gray(Cn);
        end

        [filepath,name]=fileparts(fullFileName);
        out=strcat(filepath,'\',name,'.mat');

        if ~isfile(out)
            save(out,'Cn_all','Cn','PNR','gSig','n_enhanced','F');
        else
            save(out,'Cn_all','Cn','PNR','gSig','n_enhanced','F','-append');
        end
 end

end