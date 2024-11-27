function opt=detrend_batch_and_calculate_projections(opt,opt_all)
opt_g=opt;
for k=1:length(opt_g.input_files)
    fullFileName = opt_g.input_files{k};
    [filepath,name]=fileparts(fullFileName);
    out{k}=strcat(filepath,filesep,name,'_det','.h5');
    if ~isfile(out{k})
        fprintf(1, 'Detrending and calculating relevant projections for %s\n', fullFileName);
        Vid=h5read(fullFileName,'/Object');
        [Vid,P,R(k),opt]=get_projections_and_detrend(Vid,opt_g); %#ok
        saveh5(Vid,out{k},'rootname','Object');
        opt.range=R(k);
        F=size(Vid,3);
        F_all(k)=F; %#ok
        Cn=max(P.(3){1,1},[],3);
        opt.Cn_scale=max(Cn,[],'all');
        opt.Cn=Cn./opt.Cn_scale;
        opt.PNR=max(P.PNR{1,1} ,[],3);
        opt.F=F;
        opt.P=P;
        opt_all.inter_session_alignment=opt;
        saveh5(opt_all,out{k},'append',1,'rootname','CaliAli_options');
    else
        temp=loadh5(out{k},'/CaliAli_options/inter_session_alignment');
        R(k)=temp.range; %#ok
        F_all(k)=temp.F; %#ok
        fprintf(1, 'Calculation of projections and detrending is already done for file "%s".\n', fullFileName);
    end
end
opt=opt_g;
opt.output_files=out;
opt.range=R;
opt.F=F_all;
end



