function opt=detrend_batch_and_calculate_projections(varargin)
opt_g=int_var(varargin);
for k=1:length(opt_g.theFiles)
    fullFileName = opt_g.theFiles{k};
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_det','.h5');
    [filepath,name]=fileparts(out);
    out_mat=strcat(filepath,'\',name,'.mat');
    if ~isfile(out)
        fprintf(1, 'Detrending and calculating relevant projections for %s\n', fullFileName);
        Vid=h5read(fullFileName,'/Object');
        [Vid,P,R(k),opt]=get_projections_and_detrend(Vid,opt_g); %#ok
        saveash5(Vid,out);
        opt.range=R(k);
        if ~isfile(out_mat)
            F=size(Vid,3);
            F_all(k)=F; %#ok
            Cn=mat2gray(max(P.(3){1,1},[],3));
            PNR=max(P.PNR{1,1} ,[],3); 
            opt.F=F;
            save(out_mat,'P','F','opt','Cn','PNR');
        else
            F=size(Vid,3);
            Cn=mat2gray(max(P.(3){1,1},[],3));
            PNR=max(P.PNR{1,1} ,[],3); 
            F_all(k)=F;
            opt.F=F;
            save(out_mat,'P','F','opt','Cn','PNR','-append');
        end

        if opt.datename==1
            match = regexp(name, '\d{8}', 'match');
            if size(match,1)>0
                date_v(k) = datenum(datetime(match, 'InputFormat', 'yyyyMMdd')); %#ok
            else
                date_v(k) = k; %#ok
            end
        else
            date_v(k) = k; %#ok
        end
    else
        temp=load(out_mat,'opt');
        R(k)=temp.opt.range; %#ok
        F_all(k)=temp.opt.F; %#ok
        if temp.opt.datename==1
            match = regexp(name, '\d{8}', 'match');
            if size(match,1)>0
                date_v(k) = datenum(datetime(match, 'InputFormat', 'yyyyMMdd')); %#ok
            else
                date_v(k) = k; %#ok
            end
        else
            date_v(k) = k; %#ok
        end
            fprintf(1, 'Calculation of projections and detrending is already done for file "%s".\n', fullFileName);
        end
end
opt=opt_g;
date_v=date_v-date_v(1);
opt.date_v=date_v;
opt.range=R;
opt.F=F_all;
end



