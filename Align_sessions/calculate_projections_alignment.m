function [P,Vid]=calculate_projections_alignment(opt)

if isfile(opt.out_mat)
    m=load(opt.out_mat);
    chk=isfield(m,'P');
else
    chk=0;
end

if chk==0
    k=0;
    for i=progress(1:size(Vid,2))
        temp=Vid{i};
        M(:,:,i)=median(Vid{i},3);
        Vf(:,:,i)=adapthisteq(vesselness_PV(M(:,:,i),0,linspace(BVz(1),BVz(2),10)),'Distribution','exponential');
        temp=det_video(temp,sf,n_enhanced,gSig);
        k=k+1;
        [~,Cn(:,:,i),PNR(:,:,i)]=get_PNR_coor_greedy_PV(temp,gSig,[],[],n_enhanced);
        Vid{i}=temp;
        k=k+1;
        b1(1, [], []);
    end
    b1.release();

    Vid=vid2uint16(Vid);
    Vf=mat2gray(Vf);
    M=mat2gray(M);
    Cn=mat2gray(Cn);
    for i=1:size(Vid,2)
        X(:,:,i)=mat2gray(max(cat(3,Vf(:,:,i),medfilt2(Cn(:,:,i))),[],3));
    end
    P={M,Vf,Cn,PNR,X};
    P = array2table(P,'VariableNames',{'Mean','Vessel','Coor','PNR','Vess+Coor'});
    if ~isfile(out_mat)
        save(out_mat,'P','Cn','PNR','n_enhanced');
    else
        save(out_mat,'P','Cn','PNR','n_enhanced','-append');
    end

else
    fprintf(1, 'Projections were already calculated. Loading previous file... \n');
    fprintf(1, 'Detrending videos... \n');
     for i=1:size(Vid,2)
        temp=Vid{i};
       Vid{i}=det_video(temp,sf,n_enhanced,gSig);
     end
    Vid=vid2uint16(Vid);
    P=m.P(1,:);
end
end