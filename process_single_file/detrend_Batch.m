function detrend_Batch(sf,gSig,theFiles)
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
        if isa(V,'uint8')
            Mr=v2uint8(Mr);
        else
            Mr=v2uint16(Mr);
        end
        %% save MC video as .h5
   
        saveash5(Mr,out);
        [filepath,name]=fileparts(out);
        out_mat=strcat(filepath,'\',name,'.mat');
        get_frame_list(theFiles(k),out_mat);
        get_CnPNR_from_video(gSig,{out},size(V,3));
        
       
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



