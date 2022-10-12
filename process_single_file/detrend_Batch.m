function detrend_Batch(sf,gSig,neuron_enhance,theFiles)

if ~exist('neuron_enhance','var')
    neuron_enhance = 0;
end

if ~exist('gSig','var')
        gSig = 2.5;
end

if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
end

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_det','.h5');

    if ~isfile(out)
        V=h5read(fullFileName,'/Object');
        Mr=detrend2(sf,V);

        %% save MC video as .h5
        if neuron_enhance==1
            Mr=nhance(Mr,gSig);
        end

        if isa(V,'uint8')
            Mr=v2uint8(Mr);
        else
            Mr=v2uint16(Mr);
        end
        saveash5(Mr,out);
        [filepath,name]=fileparts(out);
        out_mat=strcat(filepath,'\',name,'.mat');
        get_frame_list(theFiles(k),out_mat);
        get_CnPNR_from_video(gSig,{out},size(V,3),neuron_enhance);
        



    end
end

end

function out=detrend2(nums,obj)
[d1,d2,d3]=size(obj);
obj=double(reshape(obj,[d1*d2,d3]));
out=detrend_PV(nums,obj);
out=out./GetSn(out);
out(isnan(out))=0;
out(isinf(out))=0;
out=reshape(out,[d1,d2,d3]);
end

function Mr=nhance(Mr,gSig)
szad=gSig*2;
Mr=single(mat2gray(Mr));
Ydcln = dirt_clean(Mr, szad, 1);
Ydcln = Ydcln + Mr;
Yblur = anidenoise(Ydcln, szad,1,4,0.1429, 0.5,1);
Mr = bg_remove(Yblur, szad,1);
[d1,d2,d3]=size(Mr);
Mr=double(reshape(Mr,[d1*d2,d3]));
Mr=Mr./GetSn(Mr);
Mr(isnan(Mr))=0;
Mr(isinf(Mr))=0;
Mr=reshape(Mr,[d1,d2,d3]);
end

