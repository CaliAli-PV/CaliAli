function opt=apply_transformations(opt)
R=opt.range;
R=single(R./max(R));

if ~isfile(opt.out_path)
    for k=1:length(opt.output_files)
        fullFileName = opt.output_files{k};
        fprintf(1, 'Applaying shifts to %s\n', fullFileName);
        Y=h5read(fullFileName,'/Object');
        Y=apply_translations(Y,opt.T(k,:),opt.T_Mask);
        Y=apply_NR_shifts(Y,opt.shifts(:,:,:,k),opt.NR_Mask);
        if opt.final_neurons
            Y=apply_NR_shifts(Y,opt.shifts_n(:,:,:,k),opt.NR_Mask_n);
        end
        if isa(Y,'uint16')
        Y=uint16(single(Y).*R(k));
        else
        Y=uint8(single(Y).*R(k));
        end
        saveh5(Y,opt.out_path,'append',1,'rootname','Object');
    end
else
    fprintf(1, 'File with name "%s" already exist.\n',opt.out_path);
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