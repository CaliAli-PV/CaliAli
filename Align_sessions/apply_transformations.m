function apply_transformations(varargin)

opt=int_var(varargin);
R=opt.range;
R=single(R./max(R));
if ~isfile(opt.out)
    for k=1:length(opt.theFiles)
        fullFileName = opt.theFiles{k};

        [filepath,name]=fileparts(fullFileName);
        fullFileName=strcat(filepath,'\',name,'_det','.h5');
        fprintf(1, 'Applaying shifts to %s\n', fullFileName);
        Vid=h5read(fullFileName,'/Object');
        Vid=apply_translations(Vid,opt.T(k,:),opt.T_Mask);
        Vid=apply_NR_shifts(Vid,opt.shifts(:,:,:,k),opt.NR_Mask);
        Vid=apply_NR_shifts(Vid,opt.shifts_n(:,:,:,k),opt.NR_Mask_n);
        if isa(Vid,'uint16')
        Vid=uint16(single(Vid).*R(k));
        else
        Vid=uint8(single(Vid).*R(k));
        end
        saveash5(Vid,opt.out);
    end
else
    fprintf(1, 'File with name "%s" already exist.\n',opt.out);
end

end

function Vid=apply_translations(Vid,T,Mask)
[d1,d2,~]=size(Mask);
f1=max(sum(Mask,1));
f2=max(sum(Mask,2));
Vid=imtranslate(Vid,T);
Vid=reshape(Vid,d1*d2,[]);
Vid=Vid(Mask,:);
Vid=reshape(Vid,f1,f2,[]);
end

function  Vid=apply_NR_shifts(Vid,S,Mask)
parfor i=1:size(Vid,3)
    Vid(:,:,i)=imwarp(Vid(:,:,i)+1,S,'FillValues',1);
end
f1=max(sum(Mask,1));
f2=max(sum(Mask,2));
Vid=reshape(Vid,size(Vid,1)*size(Vid,2),[]);
Vid(~Mask(:),:)=[];
Vid=reshape(Vid,f1,f2,[]);
end