function opt=match_video_size(opt)

for i=1:size(opt.output_files,2)
    fullFileName = opt.output_files{i};
    F(i)=loadh5(fullFileName,'/CaliAli_options/inter_session_alignment/F');
    temp=loadh5(fullFileName,'/CaliAli_options/inter_session_alignment/Cn');
    Mask{i}=ones(size(temp));
end
Mask_all = catpad_centered(3,Mask{:});
k=~max(isnan(Mask_all),[],3);
[d1,d2]=size(k);
Mask_all=reshape(reshape(Mask_all,d1*d2,[]).*k(:),d1,d2,[]);
for i=1:size(Mask_all,3)
    temp=Mask_all(:,:,i);
    [d1,d2]=size(Mask{i});
    Mask{i}=reshape(temp(~isnan(temp)),d1,d2);
end
%% replace old mask
opt.F=F;
opt.Mask=Mask;

if ~all(cellfun(@(x) numel(x), Mask) == numel(Mask{1}))
fprintf(1, 'Matching video dimensions across sessions by cropping borders...\n');
    for i=progress(1:size(opt.output_files,2))
        fullFileName = opt.output_files{i};
        %% Reshape videos
        Y=loadh5(fullFileName,'/Object');
        [d1,d2]=size(Mask{i});
        Y=reshape(Y,d1*d2,[]);
        k1=max(sum(Mask{i},1));k2=max(sum(Mask{i},2));
        mask_in=logical(Mask{i}(:));
        Y=Y(mask_in,:);
        Y=reshape(Y,k1,k2,[]);
        %reshape Projecitons
        opt=loadh5(fullFileName,'/CaliAli_options');
        temp=opt.inter_session_alignment;
        for k=1:size(temp.P,2)
            t=reshape(temp.P.(k){1,1},d1*d2,[]);
            t=t(mask_in);
            temp.P.(k){1,1}=reshape(t,k1,k2,[]);
        end

        %% reshape Cn and PNR
        t=reshape(temp.Cn,d1*d2,[]);
        t=t(mask_in,:);
        temp.Cn=reshape(t,k1,k2,[]);
        t=reshape(temp.PNR,d1*d2,[]);
        t=t(mask_in,:);
        temp.PNR=reshape(t,k1,k2,[]);
        %% Save Variables
        saveh5(Y,fullFileName,'rootname','Object');
        opt.inter_session_alignment=temp;
        saveh5(opt,fullFileName,'append',1,'rootname','CaliAli_options');
    end

else

fprintf(1, 'Number of pixel in each session correctly match!\n');
end

end